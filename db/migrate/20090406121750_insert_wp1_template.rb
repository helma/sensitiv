class InsertWp1Template < ActiveRecord::Migration
  def self.up
    p = Protocol.create(:description => "Excel template for the submission of WP1 compound information", :workpackage => Workpackage.find_by_nr(7), :audited => true, :name => "wp1_template.xls", :file => File.open("db/migrate/data/wp1_template.xls"))
  end

  def self.down
  end
end
