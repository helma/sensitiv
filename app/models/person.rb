class Person < ActiveRecord::Base

	validates_presence_of :first_name, :last_name

	has_and_belongs_to_many :experiments
	belongs_to :organisation

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
