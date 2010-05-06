module ResultsHelper

  def name_column(record)
    link_to record.name, :action => :show, :id => record.id
  end

end
