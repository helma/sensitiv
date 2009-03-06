class FixIndividuals < ActiveRecord::Migration
  def self.up
    Individual.find(:all).each do |i|
      case i.id
      when 1
        Individual.delete(i.id)
      when 2
        i.name = "Donor 490"
      when 3
        i.name = "Donor 499"
      when 4
        i.name = "Donor 504"
      when 5
        i.name = "Donor 503"
      when 6
        i.name = "Donor 506"
      end
      i.save
    end

    GrowthCondition.delete(GrowthCondition.find_by_description(nil).id)

    BioSample.find_all_by_growth_condition_id(1).each do |b|
      b.growth_condition = nil
      b.save
    end

    BioSample.find_all_by_individual_id(1).each do |b|
      b.individual = nil
      b.save
    end

  end

  def self.down
  end
end
