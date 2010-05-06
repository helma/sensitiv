class CreateResults < ActiveRecord::Migration
  def self.up
    create_table :results do |t|
			t.string :name, :description, :file
      t.integer "workpackage_id"
			t.integer "person_id"
      t.timestamps
    end
  end

  def self.down
    drop_table :results
  end
end
