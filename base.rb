TEMPLATES_BASE = 'http://github.com/srveit/rails-templates'
load_template "#{TEMPLATES_BASE}/database.rb"

run "echo TODO > README"

generate :nifty_layout

# TODO
# config.action_controller.session = {
#   :session_key => '_driving_sites_session',
#   :secret      => '2708507a9aa7ce144cd2289b976cf15bb5bbebb4b70f9a673d948cf36c534767f98a807f2e5eda6fe651fb2269c312bb3e8dc1a883c6cb3bdb89efefb8cfec67'
# }

# config.time_zone = 'Central Time (US & Canada)'
# config.active_record.colorize_logging = false

load_template "#{TEMPLATES_BASE}/gems.rb"
load_template "#{TEMPLATES_BASE}/plugins.rb"
load_template "#{TEMPLATES_BASE}/layouts.rb"
# TODO:
#  rake db:migrate
#  rake db:test:prepare

load_template "#{TEMPLATES_BASE}/git.rb"
