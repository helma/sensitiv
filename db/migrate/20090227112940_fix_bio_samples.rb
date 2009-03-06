class FixBioSamples < ActiveRecord::Migration

  def self.up

    rename_column :bio_samples, :growth_condition, :tmp_gc
    rename_column :bio_samples, :individual_name, :tmp_i
    add_column :bio_samples, :growth_condition_id, :integer
    add_column :bio_samples, :individual_id, :integer

    create_table :growth_conditions do |t|
      t.string :description
    end

    create_table :individuals do |t|
      t.string :name
    end

    BioSample.find(:all).each do |b|
      gc = GrowthCondition.create(:description => b.tmp_gc) unless gc = GrowthCondition.find_by_description(b.tmp_gc)
      b.growth_condition = gc
      i = Individual.create(:name => b.tmp_i) unless i = Individual.find_by_name(b.tmp_i)
      b.individual = i
      b.save
    end

    remove_column :bio_samples, :tmp_gc
    remove_column :bio_samples, :tmp_i
    remove_column :bio_samples, :bio_source_provider_id
    remove_column :bio_samples, :person_id
    remove_column :bio_samples, :strain_or_line_id

  end

  def self.down
  end
end
