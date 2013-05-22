# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{email_veracity_checker}
  s.version = "0.0.3"

  s.required_rubygems_version = Gem::Requirement.new(">= 1.2") if s.respond_to? :required_rubygems_version=
  s.authors = ["Kiran Chaudhari"]
  s.date = %q{2010-12-27}
  s.description = %q{Check email is exist or not without sending message}
  s.email = %q{kiran@joshsoftware.com}
  s.extra_rdoc_files = ["README", "lib/email_check.rb"]
  s.files = ["Manifest", "README", "Rakefile", "email_veracity_checker.gemspec", "lib/email_check.rb"]
  s.homepage = %q{https://github.com/joshsoftware/email_veracity_checke}
  s.rdoc_options = ["--line-numbers", "--inline-source", "--title", "Email_veracity_checker", "--main", "README"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{email_veracity_checker}
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{Check email is exist or not without sending message}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
