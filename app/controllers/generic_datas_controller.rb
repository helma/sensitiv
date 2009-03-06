class GenericDatasController < ApplicationController
  active_scaffold :generic_data do |conf|
    conf.label = "Results"
    conf.columns = [:sample,:protocols,:property,:value]
    columns[:sample].label = 'Treatment'
    columns[:value].label = 'Result'
    #conf.actions.exclude :show
    conf.actions.exclude :update
    conf.actions.exclude :create

    conf.list.per_page = 500
    #conf.subform.columns.exclude :sample
    conf.subform.columns.exclude :protocols
  end

  def conditions_for_collection
      ['sample_type IN (?)', ['Treatment']]
  end
end
