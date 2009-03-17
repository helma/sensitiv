class InsertWp8Template < ActiveRecord::Migration
  def self.up
    p = Protocol.create(:description => "Excel template for the submission of WP8 results", :workpackage => Workpackage.find_by_nr(7), :audited => true, :name => "template analysis file WP8 data_v2.xls", :file => "template analysis file WP8 data_v2.xls")
    dir = "#{RAILS_ROOT}/public/protocol/file/0000/#{sprintf("%04d",p.id)}"
    File.mv("db/migrate/data/template analysis file WP8 data_v2.xls","#{dir}/#{p.name}")
    
  end

  def self.down
  end
end
