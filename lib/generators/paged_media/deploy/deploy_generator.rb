# -*- encoding : utf-8 -*-

require 'rails/generators'

def with_banner?(message, banner = "*" * 80)
  puts("\n#{banner}\n\n#{message}\n#{banner}\n")
end

class PagedMedia::DeployGenerator < Rails::Generators::Base
argument :deploy_env, :type => :string, :default => "test"
desc """
This generator deploys to a running server environment and makes the following changes:
 1. Pulls the latest commits from develop
 2. Modifies Fedora and Solr config files
 3. Adds the thin gem to Gemfile
 4. Prepares the Rails app for deployment with bundle and db:migrate
"""

  def deploy_prepare
    with_banner?("Preparing application for deployment to #{deploy_env}")
    mytime = Time.new.strftime("%Y-%m-%d_%H%M")

    git checkout: "HPT-204_automated_deployment"
#    git fetch: "origin"
#    git pull: "origin develop"
    git checkout: "-b deployment_sprint_#{mytime}"

    gem "thin", "1.6.2"
    git rm: "-r ./jetty --quiet"
    system("bundle install")
    rake "db:migrate", env: deploy_env 

    configdir = Rails.root.join("config")
    gsub_file configdir.join("fedora.yml"), '  url: <%= "http://127.0.0.1:#{ENV[\'TEST_JETTY_PORT\'] || 8983}/fedora-test" %>', "  url: http://poplar.dlib.indiana.edu:8245/fedora", force: true
    gsub_file configdir.join("solr.yml"), '  url: <%= "http://127.0.0.1:#{ENV[\'TEST_JETTY_PORT\'] || 8983}/solr/test" %>', "  url: http://poplar.dlib.indiana.edu:8245/solr/hydra-test", force: true

    system("cp /srv/deployments/pmp/.ruby* .")    

    git add: "."
    git commit: "-m 'Preparing to deploy PMP to integration environment' --quiet"

  end

end

