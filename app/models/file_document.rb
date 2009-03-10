class FileDocument < ActiveRecord::Base

  has_many :outcomes, :as => :value
  file_column :file

  def value
    File.basename(file)
  end

end

