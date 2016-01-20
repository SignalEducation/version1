# config valid only for current version of Capistrano
lock '3.4.0'

set :application, 'learnsignal.com'
set :repo_url, 'git@github.com:SignalEducation/version1.git'

# Default branch is :master
# ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp
set :branch, 'master'

# Default deploy_to directory is /var/www/my_app_name
set :deploy_to, '/home/ec2-user/app/'

# Default value for :scm is :git
set :scm, :git

# Default value for :format is :pretty
set :format, :pretty

# Default value for :log_level is :debug
set :log_level, :debug

# Default value for :pty is false
set :pty, false

# Default value for :linked_files is []
set :linked_files, fetch(:linked_files, []).push('config/database.yml', 'config/secrets.yml', 'config/application.yml')

# Default value for linked_dirs is []
set :linked_dirs, fetch(:linked_dirs, []).push('log', 'tmp/pids', 'tmp/cache', 'tmp/shared', 'tmp/sockets', 'vendor/bundle', 'public/assets')

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for keep_releases is 5
set :keep_releases, 5

namespace :deploy do

  after :restart, :clear_cache do
    on roles(:web), in: :groups, limit: 3, wait: 10 do
      # Here we can do anything such as:
      # within release_path do
      #   execute :rake, 'cache:clear'
      # end
      namespace :symlinks do
        desc "generate and copy the symlink"
        task :generate_sitemap do
          run " cd #{release_path} && RAILS_ENV=production bundle exec rake sitemap:generate"
          run " cd #{release_path} &&  RAILS_ENV=production bundle exec rake sitemap:symlink"
        end
      end
    end
  end

end

# custom settings
set :rbenv_ruby, File.read('.ruby-version').strip
set :passenger_restart_with_sudo, true # to overcome a bug in passenger 5
