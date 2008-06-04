require 'digest/md5'
class AddGroupLeader < ActiveRecord::Migration

  def self.up
    u = User.create(:name => "group_leader", :hashed_password => Digest::MD5.hexdigest("ingo3Air") )
    Workpackage.find(:all).each do |w|
      u.workpackages << w
    end
    u.save
  end

  def self.down
    User.find_by_name("group_leader").delete
  end
end
