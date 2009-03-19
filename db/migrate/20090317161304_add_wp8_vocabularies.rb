class AddWp8Vocabularies < ActiveRecord::Migration
  def self.up
    Duration.create(:value => 48, :unit => Unit.find_by_name("hours"))
    Compound.create(:name => "Lipopolysaccharide (LPS)", :smiles => "CCCCCCCCCCCCCCCC1[C@H](OC([C@H]([C@@H]1OC(=O)CC(CCCCCCCCCCC)O)O)CO[C@H]2[C@H](C([C@@H](C(O2)CO[C@@]3(CC([C@H](C(O3)C(CO)O)O[C@H]4[C@@H](C([C@@H](C(O4)C(CO)O)OP(=O)(O)OP(=O)(O)OCCN)O[C@@H]5[C@@H](C([C@@H](C(O5)C(CO[C@@H]6[C@@H](C([C@](CO6)(C(CO)O)O)O)O)O)OP(=O)(O)O)O[C@@H]7C(C([C@@H](C(O7)CO[C@@H]8C(C([C@H](C(O8)CO)O)O)O)O)O[C@@H]9C(C([C@H](C(O9)CO)O)O)O[C@@H]1C(C([C@@H](C(O1)CO)O[C@@H]1C(C([C@H](C(O1)CO)O)OC1[C@@H](C(C([C@@H](O1)C)O[C@@H]1C(C([C@@H](C(O1)CO)O)O[C@@H]1C(C[C@H](C(O1)C)O)O)O[C@@H]1C(C([C@H](C(O1)CO)O)O)O)O)O)O)O)O[C@@H]1[C@H](C([C@@H](C(O1)CO)O)O)NC(=O)C)O)O)O)O[C@@]1(CC([C@H](C(O1)C(CO)O)O)O[C@@]1(CC([C@H](C(O1)C(CO)O)O)O)C(=O)O)C(=O)O)C(=O)O)OP(=O)(O)O)OC(=O)CC(CCCCCCCCCCC)OC(=O)CCCCCCCCCCCCC)NC(=O)CC(CCCCCCCCCCC)OC(=O)CCCCCCCCCCC)CP(=O)(O)O", :cid => 11970143)    
    Compound.create(:name => 'Medium')
    Unit.create(:name => '%')
    Unit.create(:name => 'pg/mL/10^6 cells')
    ["Cell survival","CD86 positive cells","CXCL8 relative production","CD86 RFI","CD86 stimulation index"].each do |p|
       Property.create(:name => p)
    end
    conc = Concentration.create(:value => 0.1, :unit => Unit.find_by_name("% vol/vol"))
    Solvent.create(:compound => Compound.find_by_name("DMSO"), :concentration => conc)
  end

  def self.down
  end
end
