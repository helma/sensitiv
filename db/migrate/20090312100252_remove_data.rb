class RemoveData < ActiveRecord::Migration
  def self.up

    [FloatValue, StringValue].each do |cl|
      cl.find_all_by_value(nil).each do |v|
        v.outcomes.each do |o|
          Outcome.delete(o.id)
        end
        cl.delete(v.id)
      end
    end

  end

  def self.down
  end
end
