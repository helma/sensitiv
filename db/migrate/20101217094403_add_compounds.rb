class AddCompounds < ActiveRecord::Migration
  def self.up
    YAML.load_file("./physchem.yaml").each do |c|
      unless compound = Compound.find_by_inchi(c[:inchi])
        compound = Compound.create(
          :name => c[:name],
          :cas => c[:cas],
          :smiles => c[:smiles],
          :inchi => c[:inchi]
        )
      end
      compound.update_attribute :training_compound, true
      experiment = Experiment.find(6)
      compound.experiments << experiment
      treatment = Treatment.create(:compound => compound, :experiment => experiment)
      {
        :boiling_point => "Boiling point",
        :water_solubility => "Water solubility",
        :sensitiser => "Sensitiser",
        :logP => "logP",
        :melting_point => "Melting point"
      }.each do |k,v|
        property = Property.find_by_name v
        value = StringValue.find_or_create_by_value c[:physchem][k]
        measurement = Measurement.create(:treatment => treatment, :property => property, :value => value, :experiment => experiment)
      end

      experiment = Experiment.find_by_name("derek")
      compound.experiments << experiment
      treatment = Treatment.create(:compound => compound, :experiment => experiment)
      {
        :mw => "Molecular weight",
        :logP => "logP",
        :logKp => "logKp",
        :endpoint => "Derek endpoint",
        :alert => "Derek alert",
      }.each do |k,v|
        property = Property.find_by_name v
        if k == :endpoint or k == :alert
          value = StringValue.find_or_create_by_value c[:derek][k]
        else
          value = FloatValue.find_or_create_by_value c[:derek][k]
        end
        if k == :mw
          unit = Unit.find_by_name("u")
          Calculation.create(:treatment => treatment, :property => property, :value => value, :experiment => experiment, :unit => unit)
        else
          Calculation.create(:treatment => treatment, :property => property, :value => value, :experiment => experiment)
        end
      end

      experiment = Experiment.find_by_name("llna")
      compound.experiments << experiment
      biosample = BioSample.find(47)
      solvent_compound = Compound.find_or_create_by_name(c[:llna][:vehicle])
      solvent = Solvent.create(:compound => solvent_compound) unless solvent = Solvent.find_by_compound_id(solvent_compound.id)
      treatment = Treatment.create(:compound => compound, :experiment => experiment, :solvent => solvent)
      ec3 = FloatValue.find_or_create_by_value(c[:llna][:ec3])
      unit = Unit.find_by_name("% weight/vol")
      property = Property.find_by_name("EC3")
      Calculation.create(:treatment => treatment, :property => property, :value => ec3, :experiment => experiment, :unit => unit)
      potency = StringValue.find_or_create_by_value(c[:llna][:potency])
      property = Property.find_by_name("Potency")
      Calculation.create(:treatment => treatment, :property => property, :value => potency, :experiment => experiment)
      if c[:llna][:si]
        c[:llna][:si].each do |conc,si|
          concentration = Concentration.create(:unit => unit, :value => conc)
          treatment = Treatment.create(:compound => compound, :experiment => experiment, :solvent => solvent, :concentration => concentration)
          value = FloatValue.find_or_create_by_value(si)
          Measurement.create(:treatment => treatment, :property => property, :value => value, :experiment => experiment)
        end
      end
    end
  end

  def self.down
  end
end
