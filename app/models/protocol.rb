class Protocol < ActiveRecord::Base

	has_and_belongs_to_many :experiments
	has_and_belongs_to_many :bio_samples
	has_and_belongs_to_many :treatments
	has_and_belongs_to_many :results
  belongs_to :workpackage

  file_column :file

  before_save :clean_uri

  #validate :has_protocol
  validates_presence_of :name, :message => "Please provide a name for the protocol"

  def has_protocol
    errors.add("Please enter a text, an internet address or upload a file") unless text or uri or file
  end

  def clean_uri
     unless self.uri =~ /^https?:\/\/.*/
        write_attribute :uri, "http://" + self.uri.to_s unless self.uri.blank?
     else
        write_attribute :uri, self.uri 
     end
  end


end
