class SurveyDatabasePurposeController < ApplicationController
  active_scaffold :survey_database_purpose do |config|
    config.label = "What should be the purpose of the internal database?"
    config.actions.exclude :search
    config.actions.exclude :show

    config.create.link.label = "Add opinion"

    cols = [:workpackage, :data_backup, :data_dissemination, :data_analysis, :other, :comment]

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

    config.list.columns = cols
    config.update.columns = cols
    config.create.columns = cols
  end

end
