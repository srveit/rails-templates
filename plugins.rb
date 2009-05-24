def git_plugin(user, name)
  plugin name, :git => "git://github.com/#{user}/#{name}.git"
end

# rspec
git_plugin 'dchelimsky', 'rspec'
git_plugin 'dchelimsky', 'rspec-rails'

generate :rspec
run "sed -i -e 's/--colour//' spec/spec.opts"
if File.directory?('stories')
  FileUtils.rm_rf 'stories'
end

git_plugin 'brynary', 'webrat'
git_plugin 'thoughtbot', 'paperclip'
git_plugin 'pat-maddox', 'no-peeping-toms'
git_plugin 'srveit', 'resource_controller'
git_plugin 'srveit', 'web_sg_form_builder'
file "config/initializers/plugins.rb", <<-END
ActionView::Base.default_form_builder = WebSgFormBuilder
SQLITE3_LIB_PATH = ::Config::CONFIG['bindir']
END

git_plugin 'aslakhellesoy', 'cucumber'
generate :cucumber
git_plugin 'nex3', 'haml'
run "haml —rails #{RAILS_ROOT}"
# TODO add additional plugins:
    # active_merchant
    # acts_as_tree
    # acts_as_state_machine or AASM?
    # annotate_models
    # exception_notification
    # restful_authentication
    #   script/generate authenticated user sessions --stateful
    # role_requirement
    # rspec_on_rails_nested_scaffold
    # spawn
    # workling

# TODO fix_mailer_observer_sweepers_dirs
        # create mail.rb
        # mkdir -p app/observers app/sweepers app/mailers/views
        # mkdir -p spec/observers spec/sweepers spec/mailers/views
        # add above paths to environment.rb
        # add .autotest to pick up above paths
        # add user_observer environment.rb
        # add app/mailers/application_mailer.rb
        # add lib/matchers/observer_matchers.rb
        # add to spec_helper.rb:
        #   config.include(Matchers::ObserverMatchers, :type => :observers)
        # add .autotest with mailers, observers, sweepers
        # add mailers, observers, sweepers to load_paths in environment.rb

file "config/fix_rail_gem_dependencies.rb", <<-END
require 'rails/gem_dependency'

module Rails
  class GemDependency
    def specification
      @spec ||= (Gem.source_index.search(Gem::Dependency.new(name, requirement)).sort_by { |s| s.version }.last ||
                 find_gem_spec)
    end
    def find_gem_spec
      Dir[File.join(RAILS_ROOT, 'vendor', 'gems', '*')].each do |gem_dir|
        spec_file = File.join(gem_dir, '.specification')
        next unless File.exists?(spec_file)
        specification = YAML::load_file(spec_file)
        next unless name == specification.name
        return specification
      end
    end
  end
  private

  def unpack_command
    cmd = %w(unpack) << name
    cmd << "--version" << %(#{requirement.to_s}) if requirement
    cmd
  end

end
END
