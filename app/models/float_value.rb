class FloatValue < ActiveRecord::Base

  has_many :results, :as => :result

  def to_label
    value.to_s
  end
end
