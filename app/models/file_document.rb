class FileDocument < ActiveRecord::Base

  has_many :results, :as => :result
  file_column :file

  def value
    File.basename(file)
  end

end

