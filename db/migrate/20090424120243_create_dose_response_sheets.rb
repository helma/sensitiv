class CreateDoseResponseSheets < ActiveRecord::Migration
  def self.up
    create_table :dose_response_sheets do |t|
      t.integer :cell_line, :duration
      t.timestamps
    end
  end

  def self.down
    drop_table :dose_response_sheets
  end
end
