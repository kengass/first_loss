set :application, "f_loss"
set :deploy_to, "/var/www/vhosts/amffunds.com/subdomains/docs/apps/#{application}"

default_run_options[:pty] = true
set :repository,  "git://github.com/kengass/first_loss.git" 
set :scm, "git" 
set :branch, "master" 
set :deploy_via, :remote_cache

#set :use_sudo, false
set :user, 'asarx123'
set :admin_runner, 'root'

#set :copy_remote_dir, "/var/tmp"

role :app, "docs.amffunds.com"
role :web, "docs.amffunds.com"
role :db,  "docs.amffunds.com", :primary => true



    namespace :deploy do
      desc "Restart Application" 
      task :restart, :roles => :app do
        run "touch #{current_path}/tmp/restart.txt" 
      end
      desc "Start Application -- not needed for Passenger" 
      task :start, :roles => :app do
        # nothing -- need to override default cap start task when using Passenger
      end
    end