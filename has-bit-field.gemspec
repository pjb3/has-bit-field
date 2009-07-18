# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{has-bit-field}
  s.version = "0.1.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Paul Barry"]
  s.date = %q{2009-07-17}
  s.email = %q{mail@paulbarry.com}
  s.extra_rdoc_files = [
    "LICENSE",
     "README.md"
  ]
  s.files = [
    ".document",
     ".gitignore",
     "LICENSE",
     "README.md",
     "Rakefile",
     "VERSION",
     "has-bit-field.gemspec",
     "lib/has-bit-field.rb",
     "rails/init.rb",
     "rails/init.rb",
     "test/has-bit-field_test.rb",
     "test/test_helper.rb"
  ]
  s.has_rdoc = true
  s.homepage = %q{http://github.com/pjb3/has-bit-field}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.2}
  s.summary = %q{Provides an easy way for dealing with bit fields and active record}
  s.test_files = [
    "test/has-bit-field_test.rb",
     "test/test_helper.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
