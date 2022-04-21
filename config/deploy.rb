lock "3.16.0"

set :application, "rex"
set :repo_url, "git@github.rex:libertyfish-co/ruby-license.git"

server '160.16.106.214', port: 2021, roles: [:app, :web, :db], primary: true

# user
set :user,            'deploy'
set :use_sudo,        false

# server
set :stage,           :production
set :deploy_via,      :remote_cache
set :deploy_to,       "/var/www/rails/#{fetch(:application)}"

# puma
set :puma_threads,    [4, 16]
set :puma_workers,    0
set :puma_bind,       "unix://#{shared_path}/tmp/sockets/#{fetch(:application)}-puma.sock"
set :puma_state,      "#{shared_path}/tmp/pids/puma.state"
set :puma_pid,        "#{shared_path}/tmp/pids/puma.pid"
set :puma_access_log, "#{release_path}/log/puma.access.log"
set :puma_error_log,  "#{release_path}/log/puma.error.log"
set :puma_preload_app, true
set :puma_worker_timeout, nil
set :puma_init_active_record, true

# terminal
set :pty,             true

# ssh
set :ssh_options,     {
  user: 'deploy'
}

# rvm
set :rvm_ruby_version, 'ruby-2.4.10@rex-gemset'

# environment
# ref https://github.com/capistrano/rails#symlinks
set :linked_dirs, fetch(:linked_dirs, []).push(
  'log',
  'tmp/pids',
  'tmp/cache',
  'tmp/sockets',
  'vendor/bundle',
  'public/system',
  'public/uploads'
)
set :linked_files, fetch(:linked_files, []).push(
  'config/database.yml',
  'config/secrets.yml',
  'lib/tasks/config/env.yml'
)

set  :local_path, `pwd`.chomp

# following tasks are quoted from https://github.com/joshwcomeau/ColourMatch/blob/master/config/deploy.rb

namespace :puma do
  desc 'Create Directories for Puma Pids and Socket'
  task :make_dirs do
    on roles(:app) do
      execute "mkdir #{shared_path}/tmp/sockets -p"
      execute "mkdir #{shared_path}/tmp/pids -p"
    end
  end

  before :start, :make_dirs
end

namespace :deploy do
  desc "Make sure local git is in sync with remote."
  task :check_revision do
    on roles(:app) do
      unless `git rev-parse HEAD` == `git rev-parse origin/master`
        puts "WARNING: HEAD is not the same as origin/master"
        puts "Run `git push` to sync changes."
        exit
      end
    end
  end

  desc 'Restart application'
  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
      invoke 'puma:restart'
    end
  end

  desc 'Upload database.yml and secrets.yml'
  task :upload do
    on roles(:app) do |host|
      if test "[ ! -d #{shared_path}/config ]"
        execute "mkdir -p #{shared_path}/config"
      end
      upload!('config/database.yml', "#{shared_path}/config/database.yml")
      upload!('config/secrets.yml', "#{shared_path}/config/secrets.yml")
    end
  end

  before :starting,     :upload
  before :starting,     'exam:upload'
  before :starting,     :check_revision
end

namespace :exam do
  desc 'Deploy exam question from exam-master repos'
  task :deploy do
    on roles(:app) do
      within release_path do
        with rails_env: fetch(:rails_env) do
          execute :rake, 'exam:deploy'
        end
      end
    end
  end

  desc 'Upload env.yml'
  task :upload do
    on roles(:app) do |host|
      unless File.exists?("#{fetch(:local_path)}/lib/tasks/config/env.yml")
        puts "WARNING: env.yml is NOT located at lib/tasks/config"
        puts "Run `cp -p /path/to/app/lib/tasks/config/env.yml.sample /path/to/app/lib/tasks/config/env.yml`"
        exit
      end

      if test "[ ! -d #{shared_path}/lib/tasks ]"
        execute "mkdir -p #{shared_path}/lib/tasks"
      end

      upload!('lib/tasks/config/env.yml', "#{shared_path}/lib/tasks/config/env.yml")
    end
  end
end
