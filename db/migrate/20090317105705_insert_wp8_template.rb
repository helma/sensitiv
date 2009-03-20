class InsertWp8Template < ActiveRecord::Migration

  def self.up
    Protocol.reset_column_information
    p = Protocol.create(:description => "Excel template for the submission of WP8 results", :workpackage => Workpackage.find_by_nr(7), :audited => true, :name => "wp8_template.xls", :file => "wp8_template.xls")
    dir = "#{RAILS_ROOT}/public/protocol/file/0000/#{sprintf("%04d",p.id)}"
    File.makedirs dir
    File.cp("db/migrate/data/wp8_template.xls","#{dir}/#{p.name}")
  end

  def self.down
  end
end
