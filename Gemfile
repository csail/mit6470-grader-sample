source :rubygems

gem 'sinatra', '>= 1.3.1', require: 'sinatra/base'

# Deployment support.
gem 'foreman', require: false
gem 'shotgun', '>= 0.9', require: false
gem 'unicorn', '>= 4.4.0', require: false

# CORS test server libraries.
group :cors do
  gem 'rack-cors', '>= 0.2.7', require: 'rack/cors'
end

# HTML test server libraries.
group :test do
end

# Grader app libraries.
group :grader do
  # Test HTML compiling.
  gem 'tilt', '>= 1.3.3'
  gem 'erubis', '>= 2.7.0'

  # CSS compiling.
  gem 'less', '>= 2.2.2'
  gem 'sass', '>= 3.2.2'
  gem 'therubyracer', '>= 0.10.2'

  # JS compiling
  gem 'coffee-script', '>= 2.2.0'

  # Markdown problem description compiling.
  gem 'markdpwn', '>= 0.1.5'

  # Testing.
  gem 'webkit_remote', '>= 0.4.1'
  gem 'webkit_remote_unstable', '>= 0.1.0'
end
