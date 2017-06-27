=begin
task :test do
  require 'open3'
  require 'fileutils'

  puts "\nCleaning extension build files and running all specs in native ruby mode..."
  `rm -f ext/*.bundle` && puts("rm -f ext/*.bundle")
  `rm -f ext/*.o` && puts("rm -f ext/*.o")
  Open3.popen3("ruby test/spec_suite.rb") do |stdin, stdout, stderr|
    while !stdout.eof?
      print stdout.read(1)
    end
  end

  puts "\nRunning `make` to build extensions and rerunning decoder specs..."
  Dir.chdir('ext') { `make` }
  Open3.popen3("ruby test/decode_spec.rb") do |stdin, stdout, stderr|
    while !stdout.eof?
      print stdout.read(1)
    end
  end
end

task :default => :test
=end

=begin
require 'rdoc/task'
Rake::RDocTask.new do |rdoc|
  require 'yaml'
  if File.exist?('VERSION.yml')
    config = YAML.load(File.read('VERSION.yml'))
    version = "#{config[:major]}.#{config[:minor]}.#{config[:patch]}"
  else
    version = ""
  end

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "erlectricity #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
=end

require 'rake/extensiontask'

Rake::ExtensionTask.new('decoder') do |ext|
  ext.lib_dir = "lib/erlectricity"
end

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec)

task :default => [:compile, :spec]
