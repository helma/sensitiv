set :default_stage, "staging"
require 'capistrano/ext/multistage'
set :application, "lazar"
set :repository,  "svn://www.in-silico.de/opentox/lazar-gui"

# If you aren't deploying to /u/apps/#{application} on the target
# servers (which is the default), you can specify the actual location
# via the :deploy_to variable:
#set :deploy_to, "/var/www/test/#{application}"

set :use_sudo, false

# for multistage this variable is set in config/deploy/

set(:mongrel_conf) { "#{current_path}/config/mongrel_cluster.yml" }

deploy.task :after_update_code, :roles => [:web] do
    desc "Copying the right mongrel cluster config for the current stage environment."
      run "cp -f #{release_path}/config/mongrel_#{stage}.yml #{release_path}/config/mongrel_cluster.yml"
end

# If you aren't using Subversion to manage your source code, specify
# your SCM below:
# set :scm, :subversion

role :app, "lazar.in-silico.de"
role :web, "lazar.in-silico.de"
role :db,  "lazar.in-silico.de", :primary => true

namespace :deploy do

  task :default do

    update
    run "cp -f #{release_path}/config/in-silico/java.rb #{release_path}/config/java.rb"
    run "rm -rf #{release_path}/public/data"
    run "ln -fsv #{shared_path}/system/data #{release_path}/public/data"
    run_rake "svn:up"
    run "ln -fsv #{shared_path}/system/lazar #{release_path}/vendor/plugins/lazar/lib"
    run "cp -f #{release_path}/config/in-silico/java.rb #{release_path}/config/java.rb"
    run_rake "opentox:compile_java"
    #run_rake "lazar:program:install"
    run_rake "db:schema:load"
    deploy.server.start
    restart

  end
    
  task :cold do

    update
    run "mkdir #{shared_path}/system/db" 
    run "mkdir #{shared_path}/system/data" 
    run "mkdir #{shared_path}/system/lazar" 
    run "rm -rf #{release_path}/public/data"
    run "ln -fsv #{shared_path}/system/data #{release_path}/public/data"
    run_rake "svn:up"
    run "ln -fsv #{shared_path}/system/lazar #{release_path}/vendor/plugins/lazar/lib"
    run "cp -f #{release_path}/config/in-silico/java.rb #{release_path}/config/java.rb"
    run_rake "opentox:compile_java"
    #run_rake "lazar:program:install"
    run_rake "db:schema:load"
    #start

  end
    
  desc "Deploy new version without recomiling and restarting the lazar servers"
  task :without_server do

    run "cp -f #{current_path}/db/production.sqlite3 #{shared_path}/system/db/"
    update
    run "cp -f #{release_path}/config/in-silico/java.rb #{release_path}/config/java.rb"
    run "rm -rf #{release_path}/public/data"
    run "ln -fsv #{shared_path}/system/data #{release_path}/public/data"
    run_rake "svn:up"
    run "ln -fsv #{shared_path}/system/lazar #{release_path}/vendor/plugins/lazar/lib"
    run_rake "opentox:compile_java"
    run "cp -f #{shared_path}/system/db/production.sqlite3 #{release_path}/db/"
    restart

  end

  desc "Custom restart task for thin" 
  task :restart, :roles => :app, :except => { :no_release => true } do
    thin.restart
  end

  desc "Custom start task for thin" 
  task :start, :roles => :app do
    thin.start
  end

  desc "Custom stop task for thin" 
  task :stop, :roles => :app do
    thin.stop
  end

  namespace :server do
    desc "Custom restart task for mongrel cluster" 
    task :restart, :roles => :app, :except => { :no_release => true } do
      run_rake "lazar:server:start"
    end

    desc "Custom start task for mongrel cluster" 
    task :start, :roles => :app do
      run_rake "lazar:server:start"
    end

    desc "Custom stop task for mongrel cluster" 
    task :stop, :roles => :app do
      run_rake "lazar:server:stop"
    end
  end

end

namespace :mongrel do
  [ :stop, :start, :restart ].each do |t|
    desc "#{t.to_s.capitalize} the mongrel appserver" 
    task t, :roles => :app do
      #invoke_command checks the use_sudo 
      #variable to determine how to run 
      # the mongrel_rails command
      invoke_command "mongrel_rails cluster::#{t.to_s} -C #{mongrel_conf}", :via => run_method
    end
  end
end

namespace :thin do  
  desc "start the app's Thin Cluster"  
  task :start, :roles => :app do  
  end
  %w(start stop restart).each do |action| 
  desc "#{action} the app's Thin Cluster"  
    task action.to_sym, :roles => :app do  
      run "/var/lib/gems/1.8/bin/thin #{action} -e production -d -p #{thin_port} -c #{deploy_to}/current" 
    end
  end
end

def run_rake(task)
  rake = fetch(:rake, "rake")
  rails_env = fetch(:rails_env, "production")
  run "cd #{current_release}; #{rake} RAILS_ENV=#{rails_env} #{task} -t"
end
