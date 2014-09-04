require File.expand_path("../lib/codescout/version", __FILE__)

Gem::Specification.new do |s|
  s.name        = "codescout-analyzer"
  s.version     = Codescout::VERSION
  s.summary     = "No description for now"
  s.description = "No description for now, maybe later"
  s.homepage    = "https://github.com"
  s.authors     = ["Dan Sosedoff"]
  s.email       = ["dan.sosedoff@gmail.com"]
  s.license     = "MIT"

  s.add_dependency "flog",      "4.3.0"
  s.add_dependency "flay",      "2.5.0"
  s.add_dependency "churn",     "1.0.1"
  s.add_dependency "parser",    "2.2.0.pre.4"
  s.add_dependency "ruby2ruby", "2.1.1"
  s.add_dependency "brakeman",  "2.6.2"
  s.add_dependency "rubocop",   "0.25.0"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{|f| File.basename(f)}
  s.require_paths = ["lib"]
end