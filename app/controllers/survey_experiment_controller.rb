class SurveyExperimentController < ApplicationController

  active_scaffold :survey_experiment do |config|

    config.label = "Survey of Senѕ-it-iv Experiments"
    #config.label = ""
    config.actions.exclude :search
    config.actions.exclude :show
    config.create.link.label = "Add experiment"

    cols = [:workpackage, :description, :purpose, :cell_line, :measurements, :treatment, :dose_response, :time_course, :standardised_sop, :finished, :remarks]

    columns[:workpackage].label = 'WP'
    columns[:workpackage].form_ui = :select
    columns[:description].form_ui = :textarea
    columns[:purpose].form_ui = :textarea
    columns[:cell_line].label = 'Cell line/ type(s)'
    columns[:cell_line].form_ui = :textarea
    #columns[:cell_line].description = 'Enter the cell lines/types that have been used in your experiment'
    columns[:measurements].label = 'Measurements'
    columns[:measurements].description = 'e.g. Gene/ Proteine expression, Biomarkers - please specify the endpoints fon non -omics data'
    columns[:measurements].form_ui = :textarea
    columns[:treatment].label = 'Compound treatment'
    columns[:treatment].form_ui = :checkbox
    columns[:treatment].description = "Select if your ѕamples have been treated by chemicals or proteins"
    columns[:dose_response].form_ui = :checkbox
    columns[:dose_response].description = "Select if you have treated your samples with more than one dose"
    columns[:time_course].form_ui = :checkbox
    columns[:time_course].description = "Select if your samples have been treated/measured at more than one time point"
    columns[:standardised_sop].label = 'SOP'
    columns[:standardised_sop].description = 'Select if the experiment has been performed according to a standardised SOP'
    columns[:standardised_sop].form_ui = :checkbox
    columns[:finished].description = 'Select if data for this experiment is already available'
    columns[:finished].form_ui = :checkbox
    columns[:remarks].form_ui = :textarea


    config.list.columns = cols
    config.update.columns = cols
    config.create.columns = cols
  end

  private

	def authorize_write
  end

end
