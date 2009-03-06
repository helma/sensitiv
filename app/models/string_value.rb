class StringValue < ActiveRecord::Base

  has_many :results, :as => :result
  
  def to_label
    value
  end
end

