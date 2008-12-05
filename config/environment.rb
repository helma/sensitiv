# Be sure to restart your web server when you modify this file.
# Uncomment below to force Rails into production mode when 
# you don't control web/app server and can't set it the proper way
# ENV['RAILS_ENV'] ||= 'production'

# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '2.1'

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')
require File.join(File.dirname(__FILE__), '../vendor/plugins/engines/boot')


# R and Java configuration files 
require "R.rb"
require "java.rb"

Rails::Initializer.run do |config|
  config.plugins = [:engines, :opentox, :all]
  # load gems from vendor/gems
  config.load_paths += Dir["#{RAILS_ROOT}/vendor/gems/**"].map do |dir| 
      File.directory?(lib = "#{dir}/lib") ? lib : dir
  end

  config.load_paths += %W( #{RAILS_ROOT}/vendor/src/rubygems/lib )
  # Settings in config/environments/* take precedence those specified here
  config.action_controller.session = { :session_key => "_myapp_session", :secret => "5088f3e9d90958b1a8d2f5832f00e8ed" }
  
  # Skip frameworks you're not going to use (only works if using vendor/rails)
  # config.frameworks -= [ :action_web_service, :action_mailer ]

  # Add additional load paths for your own custom dirs
  # config.load_paths += %W( #{RAILS_ROOT}/extras )
  config.load_paths += %W( #{RAILS_ROOT}/vendor/bin )
  config.load_paths -= %W( /usr/local/ )

  # Force all environments to use the same logger level 
  # (by default production uses :info, the others :debug)
  # config.log_level = :debug

  # Use the database for sessions instead of the file system
  # (create the session table with 'rake db:sessions:create')
  config.action_controller.session_store = :active_record_store

  # Use SQL instead of Active Record's schema dumper when creating the test database.
  # This is necessary if your schema can't be completely dumped by the schema dumper, 
  # like if you have constraints or database-specific column types
  # config.active_record.schema_format = :sql

  # Activate observers that should always be running
  # config.active_record.observers = :cacher, :garbage_collector

  # Make Active Record use UTC-base instead of local time
  # config.active_record.default_timezone = :utc
  
  # See Rails::Configuration for more options

	#config.action_mailer.delivery_method = :smtp
	#config.action_mailer.raise_delivery_errors = true
end

# Add new inflection rules using the following format 
# (all these examples are active by default):
# Inflector.inflections do |inflect|
#   inflect.plural /^(ox)$/i, '\1en'
#   inflect.singular /^(ox)en/i, '\1'
#   inflect.irregular 'person', 'people'
#   inflect.uncountable %w( fish sheep )
# end

# Include your application configuration below

ENV['CLASSPATH'] = "#{RAILS_ROOT}/vendor/plugins/opentox/lib/java/:#{RAILS_ROOT}/vendor/plugins/opentox/lib/java/cdk-1.1.svn-19012008.jar"
ENV['PATH'] =  "#{RAILS_ROOT}/vendor/bin:" + ENV['PATH']
ENV['GEM_HOME'] = "#{RAILS_ROOT}/vendor/lib/ruby/gems/1.8"
ENV['GEM_PATH'] = "#{RAILS_ROOT}/vendor/lib/ruby/gems/1.8"
ENV['RUBY'] = "#{RAILS_ROOT}/vendor/bin/ruby"

#ExceptionNotifier.exception_recipients = %w(helma@in-silico.de)
# defaults to exception.notifier@default.com
#ExceptionNotifier.sender_address = %("Application Error" <helma@in-silico.de>)
