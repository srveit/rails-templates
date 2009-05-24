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
  puts "pwd: #{Dir.pwd}"
  'store'
end

def db_config_for_environment(environment)
  {"username" => "#{project_name}#{environment[0, 1]}",
    "adapter" => "mysql",
    "host" => "localhost",
    "password" => generate_password,
    "database" => "#{project_name}_#{environment}"}
end

def database_config
  new_db_config = {}
  %w[development test production].each do |environment|
    new_db_config[environment] = db_config_for_environment(environment)
  end
  new_db_config
end

file 'config/database.yml', YAML.dump(database_config)
