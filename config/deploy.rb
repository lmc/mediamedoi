application = "mediamedoi"
user = "mint"
server = "192.168.0.5"
deploy_to = "/Users/mint/Sites/#{application}/"
symlink_dir = "/Library/WebServer/Documents/apps/"

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


namespace :deploy do
  task :start do ; end
  task :stop do ; end
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "touch #{File.join(current_path,'tmp','restart.txt')}"
  end

  task :generate_app_symlink, :roles => :app do
  	run "#{try_sudo} ln -s #{deploy_to}current/ #{symlink_dir}#{application}"
  end
end