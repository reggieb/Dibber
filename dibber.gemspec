$:.push File.expand_path("../lib", __FILE__)

require "dibber/version"

Gem::Specification.new do |s|
  s.name        = "dibber"
  s.version     = Dibber::VERSION
  s.authors     = ["Rob Nichols"]
  s.email       = ["rob@undervale.co.uk"]
  s.homepage    = "https://github.com/reggieb/Dibber"
  s.summary     = "Tool for seeding database from YAML."
  s.description = "Packages up code needed to pull data from YAML files when seeding, and adds a process log."
  s.license = 'MIT'
  s.files = Dir["lib/**/*"] + ["MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_development_dependency 'activesupport'
  s.add_development_dependency "minitest"
end
