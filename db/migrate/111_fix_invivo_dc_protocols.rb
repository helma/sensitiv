class FixInvivoDcProtocols < ActiveRecord::Migration
  def self.up
    tonsil_p = TextDocument.find_by_name("P-DCextrtonsil").protocol
    blood_p  = TextDocument.find_by_name("P-DCextrblood").protocol
    Experiment.find_by_name("invivoDC").bio_samples.each do |b|
      case b.organism_part.name
      when "blood"
        b.protocols << blood_p
      when "tonsil"
        b.protocols << tonsil_p
      end
    end
  end

  def self.down
  end
end
