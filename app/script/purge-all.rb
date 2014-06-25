# Copyright 2014 Indiana University
# Mark H. Wood, IUPUI University Library, 18-Jun-2014
#--
# Purge all Fedora objects outside the fedora-system: PID space.
# Prefix 'rails r' with HELP=ANYTHING for help.

if (ENV['HELP'])
  puts <<HELP
	rails runner purge-all.rb

	purges all Fedora objects outside the fedora-system: PID space.

	Specify options using environment variables:

	FHOST		the Fedora host name or address
	FPORT		the Fedora port
	FUSER		the Fedora user
	FPW		the Fedora user's password
	FCONTEXT	the Fedora context (development, test, production)

	For example:

	  FHOST=host.example.com FPORT=666 rails r purge-all.rb

	The context may also be set using rails' --environment= option:

	  rails r -e production purge-all.rb
HELP
  exit
end

host = ENV['FHOST'] || 'localhost'
port = ENV['FPORT'] || '8983'
user = ENV['FUSER'] || 'fedoraAdmin'
password = ENV['FPW'] || 'fedoraAdmin'
instance = ENV['FINSTANCE'] || (Rails.env.test? ? 'fedora-test' : 'fedora')

repository = Rubydora::Repository.new(
	url: "http://#{host}:#{port}/#{instance}",
	user: 'fedoraAdmin',
	password: 'fedoraAdmin'
)

repository.search 'pid~*' do |obj|
  if ! (obj.pid =~ /^fedora-system:/)
    printf "%s\n", obj.pid
    obj.delete
  else
    printf "Skip %s\n", obj.pid
  end
end
