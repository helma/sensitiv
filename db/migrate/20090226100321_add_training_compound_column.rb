class AddTrainingCompoundColumn < ActiveRecord::Migration
  def self.up
    add_column :compounds, :training_compound, :boolean, :default => false
  end

  def self.down
  end
end
