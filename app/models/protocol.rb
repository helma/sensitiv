require 'net/http'

class Protocol < ActiveRecord::Base

	has_and_belongs_to_many :experiments
	has_and_belongs_to_many :bio_samples
	has_and_belongs_to_many :treatments
	has_and_belongs_to_many :outcomes
  belongs_to :workpackage

  file_column :file

  before_save :clean_uri

  validate :has_protocol
  validate :has_valid_uri
  validates_presence_of :name, :message => "Please provide a name for the protocol"

  def has_protocol
    nr_doc = 0
    [text,uri,file].each do |d|
      nr_doc += 1 unless d.blank?
    end
    errors.add_to_base("Please enter a text, an internet address or upload a file.") if nr_doc == 0
    errors.add_to_base("You have provided more than one protocol. Please enter either a text, or an internet address or upload a file.") if nr_doc > 1
  end

  def has_valid_uri
    error = "The internet address #{uri} is invalid or not accessible."
    unless uri.blank?
      begin
        case Net::HTTP.get_response(URI.parse(uri))
        when Net::HTTPSuccess 
        else
          errors.add_to_base(error)
        end
      rescue
        errors.add_to_base(error)
      end
    end
  end

  def clean_uri
     unless self.uri =~ /^https?:\/\/.*/
        write_attribute :uri, "http://" + self.uri.to_s unless self.uri.blank?
     else
        write_attribute :uri, self.uri 
     end
  end


end
