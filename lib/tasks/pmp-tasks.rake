require 'rspec/core'
require 'rspec/core/rake_task'
require 'jettywrapper'
JETTY_ZIP_BASENAME = 'master'
Jettywrapper.url = "https://github.com/projecthydra/hydra-jetty/archive/#{JETTY_ZIP_BASENAME}.zip"

def system_with_command_output(command, options = {})
  pretty_command = "\n$\t#{command}"
  $stdout.puts(pretty_command)
  if !system(command)
    banner = "\n\n" + "*" * 80 + "\n\n"
    $stderr.puts banner
    $stderr.puts "Unable to run the following command:"
    $stderr.puts "#{pretty_command}"
    $stderr.puts banner
    exit!(-1) unless options.fetch(:rescue) { false }
  end
end

desc 'Run specs on travis'
task :ci do
  ENV['RAILS_ENV'] = 'test'
  ENV['TRAVIS'] = '1'
  jetty_params = Jettywrapper.load_config
  error = Jettywrapper.wrap(jetty_params) do
    Rake::Task['spec'].invoke
  end
  raise "test failures: #{error}" if error
end

desc "Deploy and start the Rails app to testing and integration server"
task :deploy_devel do

  pmp_instance = 'pmp-devel-8506'

  system_with_command_output("rails_control #{pmp_instance} stop")

  Dir.chdir("/srv/rails/") do
    system_with_command_output("rm /srv/deployments/pmp/#{pmp_instance}.tar")
    system_with_command_output("tar cf /srv/deployments/pmp/#{pmp_instance}.tar ./#{pmp_instance}")
  end

  system_with_command_output("rm -rf /srv/rails/#{pmp_instance}/*")
  system("rm ./tmp/*.zip")
  system_with_command_output("tar cf - . | (cd /srv/rails/#{pmp_instance} ; tar xpBf -)")

  system_with_command_output("rm -rf /srv/rails/#{pmp_instance}/.git")

  system_with_command_output("FHOST=poplar.dlib.indiana.edu FPORT=8245 rails r app/script/purge-all.rb")
  system_with_command_output('curl http://poplar.dlib.indiana.edu:8245/solr/hydra-test/update?commit=true -H "Content-Type: text/xml" --data-binary \'<delete><query>*:*</query></delete>\'')
  
  system_with_command_output("rails_control #{pmp_instance} start")

end

RSpec::Core::RakeTask.new(:load_paged_fixtures) do |t|
  ENV['RAILS_ENV'] = 'development'
  t.pattern = Dir.glob('app/script/load*.rb')
end

namespace :pmp do
  require "#{Rails.root}/lib/tasks/batch_import"
  desc "Process XLSX manifests"
  task :process_batches => :environment do |task, args|
    PMP::Ingest::Tasks::process_batches
  end
  desc "Import batch manifests"
  task :ingest_batches => :environment do |task, args|
    PMP::Ingest::Tasks::ingest_batches
  end
end
