class OpentoxToVersion3 < ActiveRecord::Migration
  def self.up
    Engines.plugins["opentox"].migrate(3)
  end

  def self.down
    Engines.plugins["opentox"].migrate(0)
  end
end
