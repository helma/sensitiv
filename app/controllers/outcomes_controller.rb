class OutcomesController < ApplicationController

  active_scaffold :outcome do |conf|
    conf.columns = [:type, :protocols, :property, :value, :unit]
  end

end
