load_template 'http://github.com/srveit/rails-templates/base.rb'

name = ask("What do you want a user to be called?")
generate :nifty_authentication, name
rake "db:migrate"

git :add => '.', :commit => "-m 'adding authentication'"

generate :controller, "welcome index"
route "map.root :controller => 'welcome'"
git :rm => "public/index.html"

git :add => '.', :commit => "-m 'adding wlecome controller'"
