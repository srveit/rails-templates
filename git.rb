git :init

file ".gitignore", <<-END
*~
.DS_Store
config/database.yml
db/*.sqlite3
db/schema.rb
doc/api
doc/app
doc/plugins
log/*.log
log/*.pid
tmp/**/*
END

file "lib/tasks/git.rake", <<-END
require 'rubygems'

namespace :git do

  desc "checks the rails project into git repository"
  task :checkin => :database_config do
    g = create_or_open_repo
    commit_changes(g)
    configure_repo(g)
    push_repo(g)
  end

  def working_dir
    File.expand_path(rails_root)
  end

  def create_or_open_repo
    require 'git'
    begin
      g = Git.open(working_dir)
      puts '      exists  .git'
    rescue ArgumentError
      g = Git.init(working_dir)
      puts '        init  .git'
    end
    g
  end

  def commit_changes(g)
    g.add
    if g.branches.size == 0 ||
        !(g.status.added + g.status.changed + g.status.deleted).empty?
      # No commits have been made yet
      g.commit("Initial checkin")
      puts "      commit"
    else
      puts "  checked in"
    end
  end

  def email
    ENV['EMAIL'] || 'srveit@gmail.com'
  end

  def user_name
    ENV['USER_NAME'] || 'Stephen Veit'
  end

  def clone_url
    "git@github.com:#{git_user}/#{project_name.gsub('_', '-')}.git"
  end

  def git_user
    email.split('@').first
  end

  def configure_repo(g)
    g.config('user.email', email)
    g.config('user.name', user_name)
    if g.remotes.empty?
      g.add_remote('origin', clone_url)
      puts "      remote  origin #{clone_url}"
    else
      puts "      exists  #{g.remote}"
    end
  end

  def push_repo(g)
    g.push('origin', 'master')
    puts "        push  origin => master"
  end

  def rails_root
    File.dirname(__FILE__) + '/../..'
  end
end
END

run "touch tmp/.gitignore log/.gitignore vendor/.gitignore"

git :add => '.', :commit => "-m 'initial commit'"
