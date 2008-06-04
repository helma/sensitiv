class SetAuditTrue < ActiveRecord::Migration
  def self.up
    Protocol.find(:all).each do |p|
      p.update_attribute "audited", true
    end
    Experiment.find(:all).each do |e|
      e.update_attribute "audited", true
    end
  end

  def self.down
  end
end
