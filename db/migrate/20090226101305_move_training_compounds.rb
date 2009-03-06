class SensitivTrainingCompound < ActiveRecord::Base
  belongs_to :compound
end

class MoveTrainingCompounds < ActiveRecord::Migration
  def self.up
    SensitivTrainingCompound.find(:all).each do |st|
      st.compound.training_compound = true
      st.compound.save
    end
    drop_table :sensitiv_training_compounds
  end

  def self.down
  end
end
