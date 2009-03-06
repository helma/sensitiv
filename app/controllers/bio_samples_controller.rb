class BioSamplesController < ApplicationController

  before_filter :remove_empty_columns

  active_scaffold :bio_sample do |conf|

    conf.columns = ["name", "organism", "organism_part", "sex", "individual", "developmental_stage", "cell_line", "cell_type", "growth_condition", :protocols ]

    conf.columns['organism'].form_ui = :select
    conf.columns['organism_part'].form_ui = :select
    conf.columns['sex'].form_ui = :select
    conf.columns['developmental_stage'].form_ui = :select
    conf.columns['cell_line'].form_ui = :select
    conf.columns['cell_type'].form_ui = :select
    conf.columns['protocols'].form_ui = :select

    conf.list.per_page = 500

    conf.columns.each do |c|
      c.clear_link unless c == 'protocols'
    end

    conf.update.link.page = true
    conf.create.link.page = true

  end

  def remove_empty_columns
    list_columns = [ "organism_id", "organism_part_id", "sex_id", "individual_id", "developmental_stage_id", "cell_line_id", "cell_type_id", "growth_condition_id" ]
    list_columns.each do |c|
      if BioSample.count(c, :conditions => "experiment_id = #{session[:exp_id]} AND #{c} NOT NULL", :distinct => true) == 0 
        active_scaffold_config.list.columns.exclude c.gsub(/_id/,'')
      end
    end
  end

end
