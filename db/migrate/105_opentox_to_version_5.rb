class OpentoxToVersion5 < ActiveRecord::Migration
  def self.up
    Engines.plugins["opentox"].migrate(5)
  end

  def self.down
    Engines.plugins["opentox"].migrate(3)
  end
end
