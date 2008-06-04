class OpentoxToVersion8 < ActiveRecord::Migration
  def self.up
    Engines.plugins["opentox"].migrate(8)
  end

  def self.down
    Engines.plugins["opentox"].migrate(6)
  end
end

