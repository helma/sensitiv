require 'yaml'

namespace :svn do

  desc "Update (or checkout) plugins and data from svn"
  task :up do
    tree = YAML::parse(File.open("config/svn.yml")).transform
    tree.each do |key,data|
      puts "#{key}:"
      if data
        data.each do |svn_path|
          case key
          when "plugins"
            dir = "vendor/plugins/"+File.basename(svn_path.sub(/trunk/,''))
          when "data"
            dir = "public/data/"+File.basename(svn_path)
          end
          puts "#{dir}"
          if FileTest.directory?(dir)
            puts `svn up #{dir}`
          else
            puts `svn co #{svn_path} #{dir}`
          end
        end
      end
    end
  end

  desc "Check svn status" 
  task :st do
    system "svn status"
    tree = YAML::parse(File.open("config/svn.yml")).transform
    tree.each do |key,data|
      if data
        data.each do |svn_path|
          case key
          when "plugins"
            dir = "vendor/plugins/"+File.basename(svn_path.sub(/trunk/,''))
          when "data"
            dir = "public/data/"+File.basename(svn_path)
          end
          system "svn status #{dir}"
        end
      end
    end
  end

end


