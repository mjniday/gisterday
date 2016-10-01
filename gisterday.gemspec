Gem::Specification.new do |s|
  s.name        = 'gisterday'
  s.version     = '0.0.0'
  s.date        = '2016-09-25'
  s.summary     = "A command line tool for creating Gists" 
  s.description = "A command line tool for creating Gists"
  s.authors     = ["Michael Niday"]
  s.email       = 'michael.niday@gmail.com'
  s.files       = [ "lib/gist.rb",
                    "bin/gist.rb" ]

  s.executables << 'gist'

  s.add_development_dependency 'optparse'
  s.add_development_dependency 'httparty'
  s.add_development_dependency 'json'
end