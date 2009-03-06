class Protocol < ActiveRecord::Base
	has_and_belongs_to_many :experiments
	has_and_belongs_to_many :bio_samples
	has_and_belongs_to_many :treatments
	has_and_belongs_to_many :generic_datas
  belongs_to :workpackage
  belongs_to :document, :polymorphic => true

  def to_label
    label = ""
    case self.document_type
    when "FileDocument"
      label = File.basename(document.file)
    else
      label = document.name
    end
    label
  end

end
class TextDocument < ActiveRecord::Base
  has_one :protocol, :as => :document
end
class Software < ActiveRecord::Base
  has_one :protocol, :as => :document
  #has_many :generic_datas, :as => :source
end
class Url < ActiveRecord::Base
  has_one :protocol, :as => :document
  #has_many :generic_datas, :as => :source
end
class BibliographicReference < ActiveRecord::Base
  
  has_one :protocol, :as => :document
  #has_many :generic_datas, :as => :source

  def name
    text
  end
end
class FileDocument < ActiveRecord::Base
  file_column :file#, :store_dir => "file_document/"
  has_one :protocol, :as => :document
  has_one :generic_data, :as => :value

  def to_label
    file
  end
end


class CleanupProtocols < ActiveRecord::Migration

  def self.up

    drop_table :targeted_cell_types

    add_column :protocols, :name, :string
    add_column :protocols, :text, :string
    add_column :protocols, :uri, :string
    add_column :protocols, :file, :string

    Protocol.find(:all).each do |p|
      case p.document_type
      when "TextDocument"
        p.name = p.document.name
        p.text = p.document.text
      when "Software"
        p.name = p.document.name
        p.description = p.document.description
        p.uri = p.document.url
      when "Url"
        p.name = p.document.name
        p.uri = p.document.name
      when "BibliographicReference"
        p.text = p.document.text
      when "FileDocument"
        p.name = File.basename(p.document.file)
        p.file = File.basename(p.document.file)
        dir = "#{RAILS_ROOT}/public/protocol/file/0000/#{sprintf("%04d",p.id)}"
        File.makedirs dir
        File.mv("#{RAILS_ROOT}/public/file_document/file/#{p.document.id}/#{p.name}","#{dir}/#{p.name}")
      end
      p.description = p.name if p.description.blank?
      p.save
    end

    drop_table :text_documents
    drop_table :softwares
    drop_table :urls
    drop_table :bibliographic_references
    remove_column :protocols, :document_id
    remove_column :protocols, :document_type

  end

  def self.down
  end
end
