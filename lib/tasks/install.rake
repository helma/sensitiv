desc "Install base packages"
task :base_install do |t|
   sh "apt-get install rubygems irb"
   sh "rake svn:up"
end

desc "Install opentox packages for Debian (install base packages first)"
task :opentox_install_deb do |t|
   sh "apt-get -y install sqlite3 java-jdk libsqlite3-dev ruby rubygems r-base sysutils rdoc ruby1.8-dev"
   require 'config/java.rb'
   sh "gem install -y rake sqlite3-ruby rino xml-simple rjb mechanize"
   sh "rake opentox:compile_java"
   sh "rake opentox:create_migrations"
   sh "rake db:migrate"
end

desc "Install opentox packages for Ubuntu (install base packages first)"
task :opentox_install_ub do |t|
   sh "apt-get -y install sqlite3 sun-java6-jdk libsqlite3-dev ruby rubygems r-base sysutils rdoc ruby1.8-dev"
   require 'config/java.rb'
   sh "gem install -y rake sqlite3-ruby rino xml-simple rjb mechanize"
   sh "rake opentox:compile_java"
   sh "rake opentox:create_migrations"
   sh "rake db:migrate"
end
