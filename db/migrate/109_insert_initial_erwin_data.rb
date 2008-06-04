class InsertInitialErwinData < ActiveRecord::Migration
  def self.up
    affy = Property.find_by_name("Affymetrix File")
    o = Organisation.create(:name => "Novozymes A/S",:address => "Krogshoejvej 36 DK-2880 Bagsvaerd, Denmark")
    provider = BioSourceProvider.create(:organisation => o)
    erwin = Person.create(:last_name => "Roggen", :first_name => "Erwin", :email => "elro@novozymes.com", :phone => "+45 44464220", :organisation => o)
    erwin.roles << Role.find_by_name("investigator")
    erwin.roles << Role.find_by_name("submitter")
    ann = Person.create(:last_name => "Albrekt", :first_name => "Ann-Sofie", :organisation => o)
    ann.roles << Role.find_by_name("investigator")
    e1 = Experiment.create(:name => "project0512", :date => "2005/05/12", :workpackage_id => 2)
    e1.people << [erwin,ann]
    path = "/var/www/workpackage2/Results_and_Data/project0512/"
    ["p0512_EC-IL1-TNFa_050519","p0512_EC-IL1-TNFa_050607","p0512_EC-PS0000_050519","p0512_EC-PS0000_050607","p0512_EC-unstim_050519","p0512_EC-unstim_050607"].each do |s|
      BioSample.create(:name => s, :experiment => e1, :bio_source_provider => provider)
      f = FileDocument.create(:file => File.open("#{path}#{s}.CEL")) unless f = FileDocument.find_by_file("#{s}.CEL")
      GenericData.create(:property => affy, :value => f, :experiment => e1)

    end
    e2 = Experiment.create(:name => "project0520",:date =>  "2005/05/20", :workpackage_id => 2)
    e2.people << [erwin,ann]
    path = "/var/www/workpackage2/Results_and_Data/project0520/"
    ["plyji1~k","plyji1~l","plyji1~n","plyji1~o","plyji1~q","plyji1~r","plzone~y","plzonf~0","plzonf~1","plzonf~3","plzw28~o","plzw28~p","plzw28~q","plzw28~t","plzw28~u","plzw28~v","prd9gg~g","prd9gg~h","prd9gg~i","prd9gg~l","prd9gg~m","prd9gg~n","pve956~9","pve956~a","pve956~b","pve956~c","pve956~d","pve956~e","pvflpd~k","pvflpd~m","pvflpd~n","pvflpd~p"].each do |s|
      BioSample.create(:name => s, :experiment => e2, :bio_source_provider => provider)
      f = FileDocument.create(:file => File.open("#{path}#{s}.cel")) unless f = FileDocument.find_by_file("#{s}.cel")
      GenericData.create(:property => affy, :value => f, :experiment => e2)
    end

  end

  def self.down
  end
end
