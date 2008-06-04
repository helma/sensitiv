namespace "sensitiv" do

  desc "Copy production database from Sensitiv server"
  task :copy_production_db do
    sh "rsync -avz sens-it-iv.fdm.uni-freiburg.de:/var/www/sensitiv/db/production.sqlite3 db/"
  end

  desc "Copy file documents from Sensitiv server"
  task :copy_file_documents do
    sh "rsync -avz --delete sens-it-iv.fdm.uni-freiburg.de:/var/www/sensitiv/public/file_document/ public/file_document/"
  end

  desc "Sync development database with current production database"
  task "db:development:sync" => [:copy_production_db, :copy_file_documents] do
    sh "cp db/production.sqlite3 db/development.sqlite3"
  end

end
