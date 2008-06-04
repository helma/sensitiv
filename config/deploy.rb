#require mongrel_cluster/recipes
#set :mongrel_conf, "#{current_path}/config/mongrel_cluster.yml"

set :application, "rails"
set :repository,  "svn+ssh://ch@pdp8.in-silico.de/var/local/svn-pub/sensitiv/trunk"

# If you aren't deploying to /u/apps/#{application} on the target
# servers (which is the default), you can specify the actual location
# via the :deploy_to variable:
set :deploy_to, "/var/www/#{application}"

# If you aren't using Subversion to manage your source code, specify
# your SCM below:
# set :scm, :subversion

role :app, "www.sens-it-iv-internal.org"
role :web, "www.sens-it-iv-internal.org"
role :db,  "www.sens-it-iv-internal.org", :primary => true

set :user, 'ch'
set :use_sudo, false
require 'mongrel_cluster/recipes'
set :mongrel_conf, "#{current_path}/config/mongrel_cluster.yml"
set :mongrel_rails, '/var/lib/gems/1.8/bin/mongrel_rails'

desc "Symlinks for file_column"
task :after_update_code, :roles => :app do
  run "ln -nfs #{shared_path}/doc #{release_path}/public/doc"
  run <<-CMD
  cp #{shared_path}/db/production.db #{shared_path}/db/production#{Time.now.to_a[3..5].reverse.to_s}.db
  ln -nfs #{shared_path}/db/production.db #{release_path}/db/production.db
  rake db:migrate
  CMD


end

desc <<-DESC
Spinner is run by the default cold_deploy task. Instead of using script/spinner, we're just gonna rely on Mongrel to keep itself up.
DESC
task :spinner, :roles => :app do
  application_port = 8000 #get this from your friendly sysadmin
  run "mongrel_rails start -e production -p #{application_port} -d -c #{current_path}"
end

desc "Restart the web server"
task :restart, :roles => :app do
  begin
    run "cd #{current_path} && mongrel_rails restart"
  rescue RuntimeError => e
    puts e
    puts "Probably not a big deal, so I'll just keep trucking..."
  end
end

