module TreatmentsHelper

  def outcomes_column(record)
    record.outcomes.collect{|o| h(o.name)}.join("<br/>")
  end

end
