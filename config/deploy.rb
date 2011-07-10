application = "mediamedoi"
user = "mint"
server = "192.168.0.5"
deploy_to = "/Users/mint/Sites/#{application}/"

symlink_dir = "/Library/WebServer/Documents/apps/"
apache_dir = "/etc/apache2/sites/apps/"


set :application, application
set :repository,  "."

set :scm, :git
set :deploy_via, :rsync_with_remote_cache
set :deploy_to, deploy_to

set :runner, user
set :user,   user

role :web, server                   # Your HTTP server, Apache/etc
role :app, server                   # This may be the same as your `Web` server
role :db,  server, :primary => true # This is where Rails migrations will run


after "deploy:symlink", "deploy:generate_app_symlink"
after "deploy:symlink", "deploy:generate_service_config_symlinks"
after "deploy:symlink", "deploy:run_bundle"



namespace :deploy do
  task :start do ; end
  task :stop do ; end
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "touch #{File.join(current_path,'tmp','restart.txt')}"
  end

  task :generate_app_symlink, :roles => :app do
  	run "ln -shf #{deploy_to}current/public #{symlink_dir}#{application}"
  end

  task :generate_service_config_symlinks, :roles => :app do
  	run "ln -shf #{deploy_to}current/config/service_configs/apache/ #{apache_dir}#{application}"
  end

  task :run_bundle, :roles => :app do
    run "cd #{deploy_to}current && rvmsudo rvm exec bundle install"
  end
end