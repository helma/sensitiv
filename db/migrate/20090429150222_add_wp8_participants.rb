class AddWp8Participants < ActiveRecord::Migration
  def self.up
    if vumc = Organisation.find_by_name("VUMC")
      vumc.update_attribute(:name, "VU Medical Centre")
    else
      vumc = Organisation.find_by_name("VU Medical Centre")
    end

    if cosmital = Organisation.find_by_name("Cosmital / Sens-it-iv")
      cosmital.update_attribute(:name, "P&G, Wella-Cosmital")
    else
      cosmital = Organisation.find_by_name("P&G, Wella-Cosmital")
    end

    uwe = Organisation.create(:name => "University of the West of England", :address => "Great Britain")
    umi = Organisation.create(:name => "University of Milan", :address => "Italy")
    vito = Organisation.find_by_name("VITO")
    lund = Organisation.find_by_name("Lund University Hospital, Sweden")
    alu = Organisation.create(:name => "Dept of Dermatology, University Freiburg", :address => "Freiburg, Germany")
    [
      ["Henrik Johansson", lund],
      ["Carl Borrebaeck", lund],
      ["Judith Reinders", vumc],
      ["Sue Gibbs", vumc],
      ["Charlotte Williams", uwe],
      ["Julie McLeod", uwe],
      ["Emanuela Corsini", umi],
      ["Inge Nelissen",vito],
      ["Pierre Aeby", cosmital],
      ["Philipp Esser", alu]
    ].each do |n|
      names = n[0].split(/\s+/)
      if p = Person.find_by_first_name_and_last_name(names[0],names[1])
        p.update_attribute(:organisation, n[1])
      else
        p = Person.create(:first_name => names[0],:last_name => names[1], :organisation => n[1])
      end
      puts "#{p.to_label}, #{p.organisation.name} [id: #{p.id}]"
    end

    dmso = Compound.find_by_name('DMSO')
    dmso.update_attributes(:smiles => 'CS(C)=O', :cas => '67-68-5')
    c02 = Concentration.create(:value => 0.2, :unit => Unit.find_by_name("% vol/vol"))
    Solvent.create(:compound => dmso, :concentration => c02)

  end

  def self.down
  end
end
