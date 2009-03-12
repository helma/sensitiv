class DropObsoleteColumns < ActiveRecord::Migration
  def self.up
    drop_table :data_transformations
    drop_table :data_transformations_generic_datas
    drop_table :data_transformations_protocols
    drop_table :generic_datas_protocols
  end

  def self.down
  end
end
