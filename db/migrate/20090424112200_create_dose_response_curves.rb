class CreateDoseResponseCurves < ActiveRecord::Migration

  def self.up
    create_table :dose_response_curves do |t|
      t.integer :compound_id, :result_id, :cell_line_id, :concentration_unit_id, :duration_id
      t.string :image
      t.timestamps
    end
  end

  def self.down
    drop_table :dose_response_curves
  end
end
