class HumanInteraction < ActiveRecord::Base

  def self.find_all_entrez_ids(i)
    self.find_all_by_unique_id_a(i) + self.find_all_by_unique_id_b(i)
  end

end
