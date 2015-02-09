# -*- encoding : utf-8 -*-

require 'rails/generators'

def with_banner?(message, banner = "*" * 80)
  puts("\n#{banner}\n\n#{message}\n#{banner}\n")
end

class PagedMedia::DeployGenerator < Rails::Generators::Base
argument :deploy_env, :type => :string, :default => "development"
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

    git checkout: "develop"
    git fetch: "origin"
    git pull: "origin develop"
    system("bundle install")
    git checkout: "-b deployment_sprint_#{mytime}"

    gem "thin", "1.6.2"
    git rm: "-r ./jetty --quiet"
    system("bundle install")
    rake "db:migrate", env: deploy_env 

    system("cp /srv/deployments/pmp/config/* ./config")    
    system("cp /srv/deployments/pmp/.ruby* .")    

    git add: "."
    git commit: "-m 'Preparing to deploy PMP to integration environment' --quiet"

  end

end

