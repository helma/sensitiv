class InsertListOfProperties < ActiveRecord::Migration

  def self.up

    Protocol.delete(26)
    experiment = Experiment.find(6)
    p = Protocol.find_by_description("TOXNET Database search")

    File.open("db/migrate/data/list of properties.csv").each do |line|
      #[nr,name,formula,mw,cas,melting_point,boiling_point,logP,acid_base,solubility,remarks] 
      line.gsub!(/"/,'')
      items = line.split(/,/)
      puts "#{items[0]} #{items[1]}"
      properties = {
        "Melting point" => items[5].to_s,
        "Boiling point" => items[6].to_s,
        "logP"          => items[7].to_s,
        "Acid/Base"     => items[8].to_s,
        "Solubility"    => items[9].to_s,
        "Remarks"       => items[10].to_s }

      if Compound.find_by_cas(items[4])
        unless Compound.find_by_cas(items[4]).sensitiv_training_compound
          c = Compound.find_by_cas(items[4])
          SensitivTrainingCompound.create(:compound => c)
          c.experiments << experiment
        end
        properties.each do |k,v|
          puts "\t#{k} => #{v}"
          #begin
            unless v.blank?
              data = GenericData.create(:property => Property.find_by_name(k), :value => StringValue.create(:value => v.to_s), :experiment => experiment, :sample => c)
              data.protocols << p
            end
          #rescue
          #  puts "failed!"
          #end
        end
      end
    end
  end

  def self.down
    raise ActiveRecord::IrreversableMigration
  end
end
