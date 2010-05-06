class Result < ActiveRecord::Base
  belongs_to :workpackage
  belongs_to :person
  file_column :file
end
