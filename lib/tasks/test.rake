# copy development db to test db instead of loading fixtures
require 'ftools'


Rake::TaskManager.class_eval do
  def delete_task(task_name)
    @tasks.delete(task_name.to_s)
  end
  Rake.application.delete_task("db:test:purge")
  Rake.application.delete_task("db:test:prepare")
end

namespace :db do
  namespace :test do
    task :prepare => [:environment] do
      File.copy("db/development.sqlite3","db/test.sqlite3")
    end
  end
end

