class DoseResponseCurvesDoseResponseSheets < ActiveRecord::Migration
  def self.up
    create_table :dose_response_curves_dose_response_sheets, :id => false do |t|
      t.integer :dose_response_curve_id, :dose_response_sheet_id
    end
  end

  def self.down
  end
end
