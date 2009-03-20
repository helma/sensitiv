class MoveFileDocuments < ActiveRecord::Migration

  def self.up
    Measurement.find(:all).each do |m|
      case m.value_type
      when "FileDocument"
        v = m.value
        name = File.basename(v.file)
        dir = "#{RAILS_ROOT}/public/file_document/file/0000/#{sprintf("%04d",v.id)}"
        File.makedirs dir
        File.cp("#{RAILS_ROOT}/public/file_document/file/#{v.id}/#{name}","#{dir}/#{name}")
      end
    end
  end

  def self.down
  end
end
