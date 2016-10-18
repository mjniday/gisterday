Gem::Specification.new do |s|
  s.name        = 'gisterday'
  s.version     = '1.0.0'
  s.date        = '2016-09-25'
  s.summary     = "A command line tool for creating Gists" 
  s.description = "A command line tool for creating Gists"
  s.authors     = ["Michael Niday"]
  s.email       = 'michael.niday@gmail.com'
  s.homepage    = "https://github.com/mjniday/gisterday"
  s.files       = [ "lib/gist.rb",
                    "bin/gist" ]

  s.executables << 'gist'

  s.add_development_dependency 'httparty'
  s.add_development_dependency 'json'
  s.add_development_dependency 'rspec'
  s.add_development_dependency 'webmock/rspec'
end
