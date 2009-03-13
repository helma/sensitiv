class TreatmentsController < ApplicationController

  before_filter :remove_empty_columns

  active_scaffold :treatment do |config|

    config.actions.exclude :create
    config.actions.exclude :update

    config.columns = [:bio_sample, :compound, :concentration, :duration, :solvent, :outcomes]
    config.columns[:compound].sort_by :method => 'compound.name'

    config.columns[:bio_sample].form_ui = :select
    config.columns[:compound].form_ui = :select
    config.columns[:solvent].form_ui = :select
    config.columns[:protocols].form_ui = :select

    #config.update.link.page = true
    #config.create.link.page = true
  end

  def remove_empty_columns

    list_columns = ['bio_sample_id', 'compound_id', 'concentration_id', 'duration_id', 'solvent_id']
    list_columns.each do |c|
      if Treatment.count(c, :conditions => "experiment_id = #{session[:exp_id]} AND #{c} NOT NULL", :distinct => true) == 0 
        active_scaffold_config.list.columns.exclude c.gsub(/_id/,'')
      end
    end

  end

end
