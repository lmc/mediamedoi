application = "mediamedoi"
user = "mint"
server = "192.168.0.5"
deploy_to = "/Users/mint/Sites/#{application}/"
rails_env = "production"
web_path = "/apps/mediamedoi/"
ping_path = "media_libraries"

if ENV["EXTERNAL"]
  server, ssh_options[:port] = *ENV["EXTERNAL"].split(':')
end

symlink_dir = "/Library/WebServer/Documents/apps/"
apache_dir = "/etc/apache2/sites/apps/"
god_dir = "/Users/mint/God/apps/"

ping_url = "http://#{server}#{web_path}#{ping_path}"

god_groups = ["mediamedoi-dj-high","mediamedoi-dj-normal","mediamedoi-dj-normal-remote"]

set :application, application
set :repository,  "."

set :keep_releases, 10

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
after "deploy:symlink", "deploy:generate_db_symlink"
after "deploy:symlink", "deploy:run_bundle"
after "deploy:symlink", "deploy:run_migrate"
after "deploy:symlink", "deploy:restart_delayed_jobs"



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
    run "ln -shf #{deploy_to}current/config/service_configs/god/ #{god_dir}#{application}"
  end

  task :generate_db_symlink, :roles => :app do
    run "ln -shf #{deploy_to}shared/db/ #{deploy_to}current/db/sqlite"
  end

  task :run_bundle, :roles => :app do
    run "cd #{deploy_to}current && rvmsudo rvm exec bundle install --without=development,test"
  end

  task :run_migrate, :roles => :app do
    run "cd #{deploy_to}current && rvm exec rake db:migrate RAILS_ENV=#{rails_env}"
  end

  task :restart_delayed_jobs, :roles => :app do
    god_groups.each do |group|
      run "sudo god restart #{group}"
    end
  end

  task :restart_god, :roles => :app do
    run "sudo god terminate"
    run "sudo launchctl stop mint.god"
    run "sudo launchctl start mint.god"
  end
end

namespace :install do
  task :create_app_structure, :roles => :app do
    run "mkdir #{deploy_to}"
    run "mkdir #{deploy_to}/releases"
    run "mkdir #{deploy_to}/shared"
    run "mkdir #{deploy_to}/shared/cached-copy"
    run "mkdir #{deploy_to}/shared/log"
    run "mkdir #{deploy_to}/shared/db"
  end
end