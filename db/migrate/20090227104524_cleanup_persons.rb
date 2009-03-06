class Role < ActiveRecord::Base
	has_and_belongs_to_many :people
end
class Person < ActiveRecord::Base
	has_and_belongs_to_many :experiments
	has_and_belongs_to_many :roles
	belongs_to :organisation
	has_one :bio_source_provider

	def to_label
    name = ''
    if !first_name.blank?
      name = first_name + ' '
    end
    if !last_name.blank?
      name = name + last_name
    end
    name
	end
end
class Organisation < ActiveRecord::Base
	has_many :people
	has_many :bio_source_providers
end
class BioSourceProvider < ActiveRecord::Base
	has_many :bio_samples
	belongs_to :organisation

  def to_label
    organisation.name
  end

  def name
    organisation.name
  end

end

class CleanupPersons < ActiveRecord::Migration

  def self.up
    drop_table :roles
    drop_table :people_roles

=begin
    add_column :bio_samples, :person_id, :integer

    BioSourceProvider.find(:all).each do |bp|
      person = bp.organisation.people[0]
      bp.bio_samples.each do |bs|
        bs.person = person
        bs.save
      end
    end
=end

    drop_table :bio_source_providers
  end

  def self.down
  end
end
