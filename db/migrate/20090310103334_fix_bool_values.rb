class FixBoolValues < ActiveRecord::Migration
  def self.up
    BoolValue.delete(3)
    BoolValue.delete(4)
  end

  def self.down
  end
end
