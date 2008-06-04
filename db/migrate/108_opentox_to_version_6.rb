class OpentoxToVersion6 < ActiveRecord::Migration
  def self.up
    Engines.plugins["opentox"].migrate(6)
  end

  def self.down
    Engines.plugins["opentox"].migrate(5)
  end
end
