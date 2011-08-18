require 'lib/email_check.rb'

is_valid = EmailCheck.run("kiran@joshsoftware.com", "no-reply@joshsoftware.com", "joshsoftware.com").valid?

puts "is valid: #{is_valid}"
