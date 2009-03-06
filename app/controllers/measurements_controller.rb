class MeasurementsController < ApplicationController
  active_scaffold :measurement do |conf|
    #conf.columns = [:bio_sample, :compound, :concentration, :duration, :solvent, :protocols, :measurement]
  end
end
