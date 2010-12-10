require 'resolv'
require 'net/smtp'

class EmailCheck < Net::SMTP

  class EmailCheckStatus
    attr_accessor :errors

    def self.rcpt_responses
      @@rcpt_responses ||=
      {
        -1  => :fail,         # Validation failed (non-SMTP)
        250 => :valid,        # Requested mail action okay, completed
        251 => :dunno,        # User not local; will forward to <forward-path>
        550 => :invalid,      # Requested action not taken:, mailbox unavailable
        551 => :dunno,        # User not local; please try <forward-path>
        552 => :valid,        # Requested mail action aborted:, exceeded storage allocation
        553 => :invalid,      # Requested action not taken:, mailbox name not allowed
        450 => :valid_fails,  # Requested mail action not taken:, mailbox unavailable
        451 => :valid_fails,  # Requested action aborted:, local error in processing
        452 => :valid_fails,  # Requested action not taken:, insufficient system storage
        500 => :fail,         # Syntax error, command unrecognised
        501 => :invalid,      # Syntax error in parameters or arguments
        503 => :fail,         # Bad sequence of commands
        550 => :fail,         # Unknown user
        521 => :invalid,      # <domain> does not accept mail [rfc1846]
        421 => :fail,         # <domain> Service not available, closing transmission channel
      }
    end

    def initialize(response_code, error = nil)
      errors = Array.new
      errors.push error unless error.nil?
      @response = (self.class.rcpt_responses.has_key?(response_code) ?
                   response_code : -1)
    end

    # Symbolic status of mail address verification.
    #
    # :fail         Verification failed
    # :dunno        Verification succeeded, but can't tell about validity
    # :valid        address known to be valid
    # :valid_fails  address known to be valid, delivery would have failed temporarily
    # :invalid      address known to be invalid
    def status
      @@rcpt_responses[@response]
    end

    # true if verified address is known to be valid
    def valid?
      [:valid, :valid_fails].include? self.status
      #puts "[CHECK EMAIL EXISTS] status is #{self.status}."
    end

    # true if verified address is known to be invalid
    def invalid?
      self.status == :invalid
    end
  end

  def self.run(addr, server = nil, decoy_from = nil)
    if addr.index('@').nil?
      ret = EmailCheckStatus.new(-1, error)
      puts "[CHECK EMAIL EXISTS] email is #{addr} -> no email specified"
      return ret
    end
    
    server = get_mail_server(addr[(addr.index('@')+1)..-1]) if server.nil?
    
    decoy_from = "development@einsteinindustries.com"
    domain = "einsteinindustries.com"
    ret = nil
    
    puts "[CHECK EMAIL EXISTS] email is #{addr}."
    puts "[CHECK EMAIL EXISTS] addr is #{server}."
    
    begin
      smtp = EmailCheck.new(server)
      smtp.set_debug_output $stderr
      smtp.start(domain)
      ret = smtp.check_mail_addr(domain, addr, decoy_from)
      smtp.finish

      if ret.class != String
        # ruby 1.8.7
        puts "[CHECK EMAIL EXISTS] ret success is #{ret.success?}."
        puts "[CHECK EMAIL EXISTS] ret message is #{ret.message}."
        puts "[CHECK EMAIL EXISTS] ret status is #{ret.status}."
        ret = EmailCheckStatus.new(ret.message.to_s[0..2].to_i)
      else
        # ruby 1.8.5
        ret = EmailCheckStatus.new(ret[0..2].to_i)
      end
    rescue Net::SMTPAuthenticationError, Net::SMTPServerBusy, Net::SMTPSyntaxError, Net::SMTPFatalError, Net::SMTPUnknownError => error
      ret = EmailCheckStatus.new(error.to_s[0..2].to_i, error)
      puts "[CHECK EMAIL EXISTS] ret1 is #{ret}, error is #{error.to_s[0..2]}."
    rescue IOError, TimeoutError, ArgumentError => error
      ret = EmailCheckStatus.new(-1, error)
      puts "[CHECK EMAIL EXISTS] ret2 is #{ret}, error is #{error}."
    rescue Exception => error
      ret = EmailCheckStatus.new(-1, error)
      puts "[CHECK EMAIL EXISTS] ret3 is #{ret}, error is #{error}."
    end
    
    return ret
  end

  def check_mail_addr(domain, to_addr, decoy_from = nil)
    raise IOError, 'closed session' unless @socket
    raise ArgumentError, 'mail destination not given' if to_addr.empty?
    helo domain
    mailfrom decoy_from
    rcptto to_addr
  end

  # Gets the MX record
  # Note: might need to add other records if mx is insufficient
  def self.get_mail_server(host)
    res = Resolv::DNS.new.getresources(host, Resolv::DNS::Resource::IN::MX)
    unless res.empty?
      return res.sort {|x,y| x.preference <=> y.preference}.first.exchange.to_s
    end
    nil
  end
end

#=begin
CHECK_THIS_EMAIL = ARGV[0]

if CHECK_THIS_EMAIL.nil?
  exit
end

puts EmailCheck.run(CHECK_THIS_EMAIL).valid?
#=end
