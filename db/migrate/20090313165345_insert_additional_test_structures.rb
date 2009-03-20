class InsertAdditionalTestStructures < ActiveRecord::Migration
  def self.up

    remove_column :treatments, :outcome_id
    Treatment.reset_column_information
    Property.create(:name => "Water solubility")

    new_training_compounds = [
      {
        :name => "Chlorobenzene",
        :derek => {
          "logP" => 2.19,
          "logKp" => -1.85,
          "Molecular weight" => 112.56,
          "Derek endpoint" => "Nothing to report"
        },
        :llna => {
          "Potency" => "non-sensitizer",
          :solvent => "acetone:olive oil (4:1)",
          :stimulation_indices => [
            [1.1,5],
            [1.7,10],
            [1.6,25]
          ]
        },
        :cas => "108-90-7",
        :smiles => "c1(ccccc1)Cl",
        :phys_chem => {
          "Sensitiser" => "Negative control",
          "Melting point" => "-4.52E+01 °C",
          "Boiling point" => "131.7° C",
          "logP" => 2.84,
          "Water solubility" => "498 mg/L"
        }
      },{
        :name => "4-Hydroxybenzoic acid",
        :derek => {
          "logP" => 1.03,
          "logKp" => -2.83,
          "Molecular weight" => 138.12,
          "Derek endpoint" => "Nothing to report",
        },
        :llna => {
          "Potency" => "non-sensitizer",
          :solvent => "DMSO",
          :stimulation_indices => [
            [1.4,5],
            [1.5,10],
            [1.3,25]
          ]
        },
        :cas => "99-96-7",
        :smiles => "c1(C(O)=O)ccc(O)cc1",
        :phys_chem => {
          "Sensitiser" => "Negative control",
          "Melting point" => "214.5 °C",
          "logP" => 1.58,
          "Acid/Base" => "pKa 4.54",
          "Water solubility" => "5000 mg/L"
        },
      },{
        :name => "Benzaldehyde",
        :derek => {
          "logP" => 1.8,
          "logKp" => -2.09,
          "Molecular weight" => 106.12,
          "Derek endpoint" => "Skin sensitisation, human, PLAUSIBLE",
          "Derek alert" => "Skin sensitisation, 419, Aldehyde, 1 occurence.",
        },
        :llna => {
          "Potency" => "non-sensitizer",
          :solvent => "acetone:olive oil (4:1)",
          :stimulation_indices => [
            [2.1,1],
            [1.7,2.5],
            [2.2,5],
            [1.8,10],
            [2,25]]
        },
        :cas => "100-52-7",
        :smiles => "c1(ccccc1)C=O",
        :phys_chem => {
          "Sensitiser" => "Negative control",
          "Melting point" => "-2.60E+01°C ",
          "Boiling point" => "179° C",
          "logP" => 1.48,
          "Water solubility" => "6570 mg/L"
        },
      },{
        :name => "Diethyl Phthalate ",
        :derek => {
          "logP" => 1.87,
          "logKp" => -2.75,
          "Molecular weight" => 222.24,
          "Derek endpoint" => "Nothing to report",
        },
        :llna => {
          "Potency" => "non-sensitizer",
          :solvent => "acetone:olive oil (4:1)",
          :stimulation_indices => [
            [1,25],
            [1.3,50],
            [1.5,100]]
        },
        :cas => "84-66-2",
        :smiles => "c1(c(C(OCC)=O)cccc1)C(OCC)=O",
        :phys_chem => {
          "Sensitiser" => "Negative control",
          "Melting point" => "-4.05E+01° C",
          "Boiling point" => "295° C",
          "logP" => 2.42,
          "Water solubility" => "1080 mg/L"
        },
      },{
        :name => "Octanoic acid ",
        :derek => {
          "logP" => 1.66,
          "logKp" => -2.42,
          "Molecular weight" => 144.21,
          "Derek endpoint" => "Nothing to report",
        },
        :llna => {
          "Potency" => "non-sensitizer",
          :solvent => "acetone:olive oil (4:1)",
          :stimulation_indices => [
            [0.7,10],
            [1,25],
            [1.6,50]]
        },
        :cas => "124-07-2",
        :smiles => "C(CCCCC)CC(O)=O",
        :phys_chem => {
          "Sensitiser" => "Negative control",
          "Melting point" => "16.3° C",
          "Boiling point" => "239° C",
          "logP" => 3.05,
          "Acid/Base" => "pKa 4.89",
          "Water solubility" => "789 mg/L"
        },
      },{
        :name => "Hexamethylene diisocyanate",
        :cas => "822-06-0",
        :smiles => "C(CCCN=C=O)CCN=C=O",
        :phys_chem => {
          "Sensitiser" => "Respiratory sensitiser",
          "Melting point" => "-6.70E+01° C",
          "Boiling point" => "255° C",
          "logP" => 3.2,
          "Water solubility" => "117 mg/L"
        },
      },{
        :name => "Maleic anhydride",
        :cas => "108-31-6",
        :smiles => "C1(OC(=O)C=C1)=O",
        :phys_chem => {
          "Sensitiser" => "Respiratory sensitiser",
          "Melting point" => "52.8° C",
          "Boiling point" => "202° C",
          "logP" => 1.62,
          "Water solubility" => "4910 mg/L"
        },
      },{
        :name => "Glutaraldehyde",
        :derek => {
          "logP" => 0.92,
          "logKp" => -2.67,
          "Molecular weight" => 100.12,
          "Derek endpoint" => "Skin sensitisation, human, PLAUSIBLE",
          "Derek alert" => "Skin sensitisation, 419, Aldehyde, 2 occurences.",
        },
        :llna => {
          "Potency" => "strong",
          "EC3" => 0.1,
          :solvent => "Acetone",
          :stimulation_indices => [
            [1.25,0.05],
            [4.32,0.13],
            [7.6,0.25],
            [11.6,0.5],
            [17.7,1.25],
            [18,2.5]]
        },
        :cas => "111-30-8",
        :smiles => "C(CC=O)CC=O",
        :phys_chem => {
          "Sensitiser" => "Respiratory sensitiser",
          "Melting point" => "53° C",
          "Boiling point" => "188° C",
          "logP" => -0.18,
          "Water solubility" => "1.67E+05 mg/L"
        }
      }
    ]
    
    derek = Experiment.find_by_name("derek")
    llna = Experiment.find_by_name("llna")
    phys_chem = Experiment.find_by_name("phys_chem")

    new_training_compounds.each do |tc|

      # create new compound
      if c = Compound.find_by_cas(tc[:cas]) 
        puts "Updating #{c.name} #{c.cas}"
        c = Compound.update(c.id, {:name => tc[:name], :cas => tc[:cas], :smiles => tc[:smiles], :training_compound => true})
      else
        c = Compound.create(:name => tc[:name], :cas => tc[:cas], :smiles => tc[:smiles], :training_compound => true)
        puts "Creating #{c.name} #{c.cas}"
      end

      # derek
      e = derek
      if tc[:derek]
        unless t = Treatment.find_by_compound_id_and_experiment_id(c.id,e.id)
          t = Treatment.create(:compound => c, :experiment => e) 
          puts "Creating treatment for #{c.name} #{e.name}"
          tc[:derek].each do |k,v|
            case k
            when /Derek/
              value = StringValue.create(:value => v) unless value = StringValue.find_by_value(v)
              calc = Calculation.create(:property => Property.find_by_name(k), :value => value, :treatment => t, :experiment => e)
            when "Molecular weight"
              unit = Unit.find_by_name("u")
              value = FloatValue.create(:value => v) unless value = FloatValue.find_by_value(v)
              calc = Calculation.create(:property => Property.find_by_name(k), :value => value, :treatment => t, :experiment => e, :unit => unit)
            else
              value = FloatValue.create(:value => v) unless value = FloatValue.find_by_value(v)
              calc = Calculation.create(:property => Property.find_by_name(k), :value => value, :treatment => t, :experiment => e)
            end
            t.outcomes << calc
          end
          t.save
        end
      end
      # llna
      e = llna
      if tc[:llna]
        unless t = Treatment.find_by_compound_id_and_experiment_id(c.id,e.id)
          puts "No treatments for #{c.name} #{e.name} !!!"
        end
      end
      # phys_chem
      e = phys_chem
      if tc[:phys_chem]
        unless t = Treatment.find_by_compound_id_and_experiment_id(c.id,e.id)
          t = Treatment.create(:compound => c, :experiment => e) 
          c.experiments << e
          c.save
          puts "Creating treatment for #{c.name} #{e.name}"
          tc[:phys_chem].each do |k,v|
            case k
            when "logP"
              value = FloatValue.create(:value => v) unless value = FloatValue.find_by_value(v)
              m = Measurement.create(:property => Property.find_by_name(k), :value => value, :treatment => t, :experiment => e)
            else
              value = StringValue.create(:value => v) unless value = StringValue.find_by_value(v)
              m = Measurement.create(:property => Property.find_by_name(k), :value => value, :treatment => t, :experiment => e)
            end
            puts m.data
            m.save
          end
          t.save
        end
      end
      c.save
    end

  end

  def self.down
  end
end
