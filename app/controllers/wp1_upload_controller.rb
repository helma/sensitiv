require 'roo'

class Wp1UploadController <  ActionController::Base

  layout 'sensitiv'

  def index
  end

  def layout

    @sheets = {
      :compounds => 0,
      :derek  => 1,
      :llna => 2,
      :phys_chem => 3
    }

    @columns = {
      :compounds => {:name => 1, :cas => 2, :smiles => 3},
      :derek     => {"logP" => 2, "logKp" => 3, "Molecular weight" => 4, "Derek endpoint" => 5, "Derek alert" => 6},
      :llna      => {"Potency" => 2, "EC3" => 3,"Solvent" => 4, :stimulation_indices => [5,7,9,11,13]},
      :phys_chem => {"Sensitiser" => 2, "Melting point" => 3, "Boiling point" => 4, :logP => 5, "Acid/Base" => 6, "Water solubility" => 7}
    }

  end

  def new

    flash[:warning] = "You did not send an Excel file" unless params[:file].content_type == 'application/vnd.ms-excel'
    flash[:notice] = "#{params[:file].original_filename} uploaded"

    # upload sheet
    excel = RAILS_ROOT+'/public/wp1_submissions/'+params[:file].original_filename
    File.mv(params[:file].path,excel)
    layout
    xl = Excel.new(excel)
    wp = Workpackage.find_by_nr(1)

    xl.default_sheet = xl.sheets[@sheets[:compounds]]
    xl.first_row.upto(xl.last_row) do |row|
      unless row == 1

        # compound
        xl.default_sheet = xl.sheets[@sheets[:compounds]]
        cas = xl.cell(row,@columns[:compounds][:cas])
        if compound = Compound.find_by_cas(cas)
          compound.update_attributes(
            :name => xl.cell(row,@columns[:compounds][:name]),
            :smiles =>  xl.cell(row,@columns[:compounds][:smiles]),
            :training_compound => true
          )
        else
          compound = Compound.create(
            :name => xl.cell(row,@columns[:compounds][:name]),
            :cas => cas,
            :smiles =>  xl.cell(row,@columns[:compounds][:smiles]),
            :training_compound => true
          )
        end

        # llna
        xl.default_sheet = xl.sheets[@sheets[:llna]]
        experiment = Experiment.find_by_name("llna")
        biosample = BioSample.find(47)
        solvent_name = xl.cell(row,@columns[:llna]["Solvent"])
        solvent_compound = Compound.find_or_create_by_name(solvent_name)
        solvent = Solvent.find_or_create_by_compound_id_and_concentration_id(solvent_compound.id,nil)
        treatments = Treatment.find_all_by_compound_id_and_experiment_id_and_bio_sample_id(compound.id,experiment.id,biosample.id)
        treatments.each do |t|
          Treatment.delete(t.id)
        end

        @columns[:llna].each do |name,col|
          case name.to_s
          when "Potency"
            treatment = Treatment.find_or_create_by_compound_id_and_experiment_id_and_bio_sample_id_and_solvent_id(compound.id,experiment.id,biosample.id,solvent.id)
            v = xl.cell(row,col)
            value = StringValue.find_or_create_by_value(v)
            property = Property.find_by_name(name)
            if calc = Calculation.find_or_create_by_property_id_and_treatment_id_and_experiment_id(property.id,treatment.id,experiment.id)
              calc.update_attributes(:property => property, :value => value, :treatment => treatment, :experiment => experiment)
            else
              calc = Calculation.create(:property => property, :value => value, :treatment => treatment, :experiment => experiment)
              treatment.outcomes << calc
              treatment.save
            end
          when "EC3"
            treatment = Treatment.find_or_create_by_compound_id_and_experiment_id_and_bio_sample_id_and_solvent_id(compound.id,experiment.id,biosample.id,solvent.id)
            v = xl.cell(row,col)
            value = FloatValue.find_or_create_by_value(v)
            property = Property.find_by_name(name)
            unit = Unit.find_by_name("% weight/vol")
            if calc = Calculation.find_or_create_by_property_id_and_treatment_id_and_experiment_id_and_unit_id(property.id,treatment.id,experiment.id,unit.id)
              calc.update_attributes(:property => property, :value => value, :treatment => treatment, :experiment => experiment, :unit => unit)
            else
              calc = Calculation.create(:property => property, :value => value, :treatment => treatment, :experiment => experiment, :unit => unit)
              treatment.outcomes << calc
              treatment.save
            end
          when "stimulation_indices" 
            col.each do |column|
              conc_value = xl.cell(row,column+1)
              unless conc_value.blank?
                conc_unit = Unit.find_by_name("% weight/vol")
                concentration = Concentration.find_or_create_by_value_and_unit_id(conc_value,conc_unit.id)
                treatment = Treatment.find_or_create_by_compound_id_and_experiment_id_and_bio_sample_id_and_solvent_id_and_concentration_id(compound.id,experiment.id,biosample.id,solvent.id,concentration.id)
                si_value = FloatValue.find_or_create_by_value(xl.cell(row,column))
                property = Property.find_by_name("Stimulation Index")

                if m = Measurement.find_by_property_id_and_treatment_id_and_experiment_id(property.id,treatment.id,experiment.id)
                  m.update_attribute(:value, si_value)
                else
                  m = Measurement.create(:property => property, :value => si_value, :treatment => treatment, :experiment => experiment)
                end
              end
            end
          end
        end

        # derek
        xl.default_sheet = xl.sheets[@sheets[:derek]]
        experiment = Experiment.find_by_name("derek")
        unless treatment = Treatment.find_by_compound_id_and_experiment_id(compound.id,experiment.id)
          treatment = Treatment.create(:compound => compound, :experiment => experiment) 
          compound.experiments << experiment
          compound.save
        end
        @columns[:derek].each do |name,col|
          case name.to_s
          when /Derek/
            v = xl.cell(row,col)
            value = StringValue.create(:value => v)  unless value = StringValue.find_by_value(v)
            property = Property.find_by_name(name)
            if calc = Calculation.find_by_property_id_and_treatment_id_and_experiment_id(property.id,treatment.id,experiment.id)
              calc.update_attributes(:property => property, :value => value, :treatment => treatment, :experiment => experiment)
            else
              calc = Calculation.create(:property => property, :value => value, :treatment => treatment, :experiment => experiment)
              treatment.outcomes << calc
            end
          when "Molecular weight"
            v = xl.cell(row,col)
            unit = Unit.find_by_name("u")
            property = Property.find_by_name(name)
            value = FloatValue.create(:value => v) unless value = FloatValue.find_by_value(v)
            if calc = Calculation.find_by_property_id_and_treatment_id_and_experiment_id(property.id,treatment.id,experiment.id)
              calc.update_attributes(:property => property, :value => value, :treatment => treatment, :experiment => experiment, :unit => unit)
            else
              calc = Calculation.create(:property => property, :value => value, :treatment => treatment, :experiment => experiment, :unit => unit)
              treatment.outcomes << calc
            end
          else
            v = xl.cell(row,col)
            property = Property.find_by_name(name)
            value = FloatValue.create(:value => v) unless value = FloatValue.find_by_value(v)
            if calc = Calculation.find_by_property_id_and_treatment_id_and_experiment_id(property.id,treatment.id,experiment.id)
              calc.update_attributes(:property => property, :value => value, :treatment => treatment, :experiment => experiment)
            else
              calc = Calculation.create(:property => property, :value => value, :treatment => treatment, :experiment => experiment)
              treatment.outcomes << calc
            end
          end
        end
        treatment.save

        # phys_chem
        xl.default_sheet = xl.sheets[@sheets[:phys_chem]]
        experiment = Experiment.find_by_name("phys_chem")
        unless treatment = Treatment.find_by_compound_id_and_experiment_id(compound.id,experiment.id)
          treatment = Treatment.create(:compound => compound, :experiment => experiment) 
          compound.experiments << experiment
          compound.save
        end
        @columns[:phys_chem].each do |name,col|
          case name.to_s
          when 'logP'
            v = xl.cell(row,col)
            value = FloatValue.create(:value => v) unless value = FloatValue.find_by_value(v)
            property = Property.find_by_name(name.to_s)
            if m = Measurement.find_by_property_id_and_treatment_id_and_experiment_id(property.id,treatment.id,experiment.id)
              m.update_attributes(:property => property, :value => value, :treatment => treatment, :experiment => experiment)
            else
              m = Measurement.create(:property => property, :value => value, :treatment => treatment, :experiment => experiment)
              treatment.outcomes << m
            end
          else
            v = xl.cell(row,col)
            value = StringValue.create(:value => v) unless value = StringValue.find_by_value(v)
            property = Property.find_by_name(name.to_s)
            if m = Measurement.find_by_property_id_and_treatment_id_and_experiment_id(property.id,treatment.id,experiment.id)
              m.update_attributes(:property => property, :value => value, :treatment => treatment, :experiment => experiment)
            else
              m = Measurement.create(:property => property, :value => value, :treatment => treatment, :experiment => experiment)
              treatment.outcomes << m
            end
          end
        end
        treatment.save
      end
    end
    redirect_to :action => :index
    
  end

end
