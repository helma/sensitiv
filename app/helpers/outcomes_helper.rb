module OutcomesHelper

  def value_column(record)
    case record.value.class.to_s
    when "FileDocument"
      link_to(File.basename(record.value.file), url_for_file_column(record.value, 'file'))
    else
      record.value.value
    end
  end

end
