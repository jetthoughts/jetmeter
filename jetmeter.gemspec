require 'jetmeter/version'

Gem::Specification.new do |s|
  s.name    = 'jetmeter'
  s.version = Jetmeter::VERSION
  s.authors = ['Mark Volosiuk']
  s.email   = ['marchi.martius@gmail.com']

  s.description = 'Jetmeter is a tool to analyze github repo activity'
  s.license = 'BSD-2-Clause'

  s.files   = Dir['lib/*.rb'] + Dir['bin/*']
  
  s.executables << 'jetmeter'

  s.add_runtime_dependency 'octokit', ['~> 4.7.0']

  s.add_development_dependency 'rake', ['~> 12.0.0']
  s.add_development_dependency 'minitest', ['~> 5.10.2']
end
