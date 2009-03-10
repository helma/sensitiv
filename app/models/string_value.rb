class StringValue < ActiveRecord::Base

  has_many :outcomes, :as => :value
  
  def to_label
    value
  end
end

