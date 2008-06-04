class AddAuditColumn < ActiveRecord::Migration
  def self.up
    add_column :protocols, :audited, :boolean, :default => false
    add_column :experiments, :audited, :boolean, :default => false
  end

  def self.down
    remove_column :experiments, :audited
    remove_column :protocols, :audited
  end
end
