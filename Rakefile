require 'rake/extensiontask'

Rake::ExtensionTask.new('decoder') do |ext|
  ext.lib_dir = "lib/erlectricity"
end

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec)

task :default => [:compile, :spec]
