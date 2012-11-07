$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "dibber/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "dibber"
  s.version     = Dibber::VERSION
  s.authors     = ["Rob Nichols"]
  s.email       = ["rob@undervale.co.uk"]
  s.homepage    = "https://github.com/reggieb/Dibber"
  s.summary     = "Tool for seeding database from YAML."
  s.description = "Packages up code needed to pull data from YAML files when seeding, and adds a process log."

  s.files = Dir["lib/**/*"] + ["MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]
end
