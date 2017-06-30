Gem::Specification.new do |s|
  s.name = %q{erlectricity}
  s.version = "1.1.1"

  s.authors = ["Scott Fleckenstein", "Tom Preston-Werner"]
  s.date = %q{2009-10-28}
  s.email = %q{tom@mojombo.com}
  s.extensions = ["ext/decoder/extconf.rb"]
  s.extra_rdoc_files = ["LICENSE", "README.md"]

  s.files = Dir["*", "{benchmarks,examples,ext,lib,test}/**/*"]
  s.homepage = %q{http://github.com/mojombo/erlectricity}
  s.rdoc_options = ["--charset=UTF-8"]
  s.rubygems_version = %q{1.3.5}
  s.summary = %q{A library to interface erlang and ruby through the erlang port system}

  s.add_development_dependency "rake-compiler"
  s.add_development_dependency "rspec"
  s.add_development_dependency "simplecov"
end
