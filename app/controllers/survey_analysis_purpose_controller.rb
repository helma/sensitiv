class SurveyAnalysisPurposeController < ApplicationController
  active_scaffold :survey_analysis_purpose do |config|

    config.label = "What should be the purpose of data analysis?"
    config.actions.exclude :search
    config.actions.exclude :show

    config.create.link.label = "Add opinion"

    cols = [:workpackage, :biomarker_identification, :pathway_identification, :assay_comparison, :evaluation_of_experimental_conditions, :other, :comment ]

    columns[:workpackage].label = 'WP'
    columns[:biomarker_identification].description = 'Identification of biomarkers that discriminate between sensitisers and non-sensitisers'
    columns[:pathway_identification].description = 'Identification of pathways that are affected by sensitisers'
    #columns[:assay_comparison].label = 'Comparison of assays'
    #columns[:experimental_condition].label = 'Evaluation of experimental conditions'
    #columns[:assay_validation].label = 'Comparison of cell lines/assays'

    cols.each do |c|
      case c
      when :workpackage
        columns[c].label = 'WP'
        columns[c].form_ui = :select
      when :other
        columns[c].form_ui = :textarea
      when :comment
        columns[c].form_ui = :textarea
      else
        columns[c].form_ui = :checkbox
      end
    end
    columns[:workpackage].form_ui = :select

    config.list.columns = cols
    config.update.columns = cols
    config.create.columns = cols
  end

  private

	def authorize_write
  end
end
