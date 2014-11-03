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
task :deploy_test do

  system_with_command_output("rails_control pmp-test-8506 stop")

  Dir.chdir("/srv/rails/") do
    system_with_command_output("rm /srv/deployments/pmp/pmp-test-8506.tar")
    system_with_command_output("tar cf /srv/deployments/pmp/pmp-test-8506.tar ./pmp-test-8506")
  end

  system_with_command_output("rm -rf /srv/rails/pmp-test-8506/*")
  system("rm ./tmp/*.zip")
  system_with_command_output("tar cf - . | (cd /srv/rails/pmp-test-8506 ; tar xpBf -)")

  system_with_command_output("rm -rf /srv/rails/pmp-test-8506/.git")

  system_with_command_output("FHOST=poplar.dlib.indiana.edu FPORT=8245 rails r app/script/purge-all.rb")
  system_with_command_output('curl http://poplar.dlib.indiana.edu:8245/solr/hydra-test/update?commit=true -H "Content-Type: text/xml" --data-binary \'<delete><query>*:*</query></delete>\'')
  
  system_with_command_output("rails_control pmp-test-8506 start")

end

RSpec::Core::RakeTask.new(:load_paged_fixtures) do |t|
  ENV['RAILS_ENV'] = 'development'
  t.pattern = Dir.glob('app/script/load*.rb')
end
