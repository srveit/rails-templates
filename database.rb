require 'active_record'

def character_set
  "ABCDEFGHIJKLMNOPQRSTUVWXYZ01234567890abcdefghijklmnopqrstuvwxyz"
end

def generate_password
  password = ''
  25.times do
    password += character_set[rand(character_set.length), 1]
  end
  password
end

def project_name
  File.basename(RAILS_ROOT)
end

def db_config_for_environment(environment)
  {"username" => "#{project_name}#{environment[0, 1]}",
    "adapter" => "mysql",
    "host" => "localhost",
    "password" => generate_password,
    "database" => "#{project_name}_#{environment}"}
end

def database_config
  unless @new_db_config
    @new_db_config= {}
    %w[development test production].each do |environment|
      @new_db_config[environment] = db_config_for_environment(environment)
    end
  end
  @new_db_config
end

def add_database_user(config)
  ['%', 'localhost', `hostname`.strip].each do |hostname|
    user_hostname = "'#{config['username']}'@'#{hostname}'"
    cmd = "GRANT ALL ON #{config['database']}.* TO " +
      "#{user_hostname} " +
      "IDENTIFIED BY '#{config['password']}'"
    ActiveRecord::Base.connection.execute(cmd)
    cmd = "GRANT FILE ON *.* TO #{user_hostname}"
    ActiveRecord::Base.connection.execute(cmd)
    puts "         add  user #{user_hostname} to #{config['database']}"
  end
end

def root_config
  {'adapter' => 'mysql',
    'database' => 'mysql',
    'username' => root_username,
    'password' => root_password}
end

def root_password
  root_password_env = 'MYSQL_ROOT_PASS'
  # TODO: use ask?
  ENV[root_password_env] || 
    raise("Environment variable #{root_password_env} not set")
end

def root_username
  ENV['MYSQL_ROOT_USER'] || 'root'
end

def create_database(config)
  begin
    puts "connecting to #{config.inspect} dir #{Dir.pwd}"
    ActiveRecord::Base.establish_connection(config)
    ActiveRecord::Base.connection
  rescue
    case config['adapter']
    when 'mysql'
      @charset   = ENV['CHARSET']   || 'utf8'
      @collation = ENV['COLLATION'] || 'utf8_general_ci'
      begin
        ActiveRecord::Base.establish_connection(root_config)
        begin
          ActiveRecord::Base.connection.create_database(config['database'],
                                                        {:charset => @charset,
                                                          :collation => @collation})
          puts "      create  database #{config['database']}"
        rescue ActiveRecord::StatementInvalid => e
          raise unless e.message =~ /database exists/
          puts "      exists  database #{config['database']}"
        end
        add_database_user(config)
        ActiveRecord::Base.establish_connection(config)
        ActiveRecord::Base.connection
      rescue => e
        $stderr.puts e
        $stderr.puts "Couldn't create database for #{config.inspect}"
      end
    when 'postgresql'
      `createdb "#{config['database']}" -E utf8`
    when 'sqlite'
      `sqlite "#{config['database']}"`
    when 'sqlite3'
      `sqlite3 "#{config['database']}"`
    end
  else
    puts "      exists  database #{config['database']}"
  end
end

def create_databases(db_config)
  db_config.each do |environmment, config|
    next unless config['database']
    if %w( 127.0.0.1 localhost ).include?(config['host']) || config['host'].blank?
      Dir.chdir(rails_root) do
        create_database(config)
      end
    end
  end
end

file 'config/database.yml', YAML.dump(database_config)

create_databases(database_config)
