require 'roo'

class Wp8UploadController <  ActionController::Base

  layout 'sensitiv'

  def index
  end

  def parse(xl)

    # define layout of excel sheet here
    # cell arguments: row, column, sheet

    # read single cells
    
    # first sheet
    xl.default_sheet = xl.sheets[0]

    data = {
      :experiment => {
        :number => xl.cell(2,2),
        :title => xl.cell(3,2),
        :description => xl.cell(4,2)
      },
      :submitter => xl.cell(6,2),
    }

    # second sheet
    xl.default_sheet = xl.sheets[1]
    data[:cell_line] = xl.cell(1,3),
    data[:treatment_time] = xl.cell(2,3),
    data[:solvent_concentration] = xl.cell(8,7),

    # read ranges
    ranges = {

      :replicates => 2,

      :control_row => 8,

      :control_columns => {
        :medium =>  2,
        :lps => 4,
        :dmso => 6
      }, 

      :compounds => {
        :row => 7,
        :start_column => 10, # 'J'
        :nr => 4
      },

      :concentrations => {
        :row => 8,
        :nr => 4,
        :column_size => 2
      },

      :measurement_rows => {
        "Cell survival" => 10,
        "CD86 RFI" => 18,
        "CD86 positive cells" => 25,
        "CD86 stimulation index" => 32,
        "CXCL8 relative production" => 39
      }

    }

    # parse ranges

    # controls
    data[:treatments] = []
    ranges[:control_columns].each do |control,col|
      name = xl.cell(ranges[:control_row],col)
      ranges[:replicates].times do 
        treatment = {
          :compound => name,
          :measurements => {}
        }
        ranges[:measurement_rows].each do |m,row|
          treatment[:measurements][m] = xl.cell(row,col)
        end
        col += 1
        data[:treatments] << treatment
      end
    end

    # compounds
    col = ranges[:compounds][:start_column]
    ranges[:compounds][:nr].times do
      name = xl.cell(ranges[:compounds][:row],col)
      conc_unit = xl.cell(ranges[:compounds][:row],col+7)
      ranges[:concentrations][:nr].times do 
        conc = xl.cell(ranges[:concentrations][:row],col)
        ranges[:replicates].times do 
          treatment = {
            :compound => name,
            :concentration => conc,
            :concentration_unit => conc_unit,
            :measurements => {}
          }
          ranges[:measurement_rows].each do |m,row|
            treatment[:measurements][m] = xl.cell(row,col)
          end
          col += 1
          data[:treatments] << treatment
        end
      end
      col += 1
    end

    data 

  end

  def new

    flash[:warning] = "You did not send an Excel file" unless params[:file].content_type == 'application/vnd.ms-excel'
    flash[:notice] = "#{params[:file].original_filename} uploaded"

    # upload sheet
    tmp_excel = RAILS_ROOT+'/public/wp8_submissions/'+params[:file].original_filename
    File.mv(params[:file].path,tmp_excel)
    data = parse(Excel.new(tmp_excel))

    wp = Workpackage.find_by_nr(8)

    experiment = Experiment.create(
      :name => params[:file].original_filename,
      :title => data[:experiment][:title],
      :description => data[:experiment][:description] + " [Experiment Nr. " + data[:experiment][:number].to_s + "]",
      :workpackage => wp,
      :date => Date.today
    )

    submitter_id = data[:submitter].sub(/.*\[id: (\d+)\]/,'\1').to_i
    person = Person.find(submitter_id)
    person.experiments << experiment
    person.save

    cell_line = CellLine.find_by_name(data[:cell_line])
    organism = Organism.find_by_name('human')
    organism_part = OrganismPart.find_by_name("blood")
    cell_type = CellType.find_by_name("acute myelomonocytic leukemia")
    sex = Sex.find_by_name("male")

    duration = Duration.find_by_value_and_unit_id(data[:treatment_time],Unit.find_by_name("hours").id)
    solvent = nil
    unless data[:solvent_concentration].to_f == 0
      solvent_concentration = Concentration.find_or_create_by_value_and_unit_id(data[:solvent_concentration], Unit.find_by_name("% vol/vol").id)
      dmso = Compound.find_by_name('DMSO')
      solvent = Solvent.find_by_compound_id_and_concentration_id(dmso,solvent_concentration)
    end

    bio_sample_name = 0
    data[:treatments].each do |t|

      bio_sample_name += 1
      bio_sample = BioSample.create(:name => bio_sample_name, :cell_line => cell_line, :organism => organism, :organism_part => organism_part, :cell_type => cell_type, :sex => sex)

      conc_unit = nil
      case t[:concentration_unit]
      when "mM"
        conc_unit = Unit.find_by_name("mM")
      else
        conc_unit = Unit.find_by_name("uM")
      end

      concentration = Concentration.find_or_create_by_value_and_unit_id(t[:concentration], conc_unit.id)
      treatment = nil

      case t[:compound]
      when /id:/
        compound_id = t[:compound].sub(/.*\[id: (\d+)\]/,'\1').to_i
        compound = Compound.find(compound_id)
        treatment = Treatment.create(:compound => compound, :duration => duration, :bio_sample => bio_sample, :concentration => concentration, :solvent => solvent, :experiment => experiment)
      when "medium"
        compound = Compound.find_by_name("Medium")
        treatment = Treatment.create(:compound => compound, :duration => duration, :bio_sample => bio_sample, :experiment => experiment)
      when 'LPS'
        compound = Compound.find_by_name("Lipopolysaccharide (LPS)")
        treatment = Treatment.create(:compound => compound, :duration => duration, :bio_sample => bio_sample, :experiment => experiment)
      when /DMSO/
        treatment = Treatment.create(:duration => duration, :bio_sample => bio_sample, :solvent => solvent, :experiment => experiment) unless data[:solvent_concentration].to_i == 0
      end

      if treatment
        t[:measurements].each do |name,result|

          unless result.blank?
            case name
            when /Cell survival|CD86 positive cells/
              unit = Unit.find_by_name('%')
            when "CXCL8 relative production" 
              unit = Unit.find_by_name('pg/mL/10^6 cells')
            else
              unit = nil
            end

            property = Property.find_by_name(name)
            value = FloatValue.create(:value => result) unless value = FloatValue.find_by_value(result)
            Measurement.create(:treatment => treatment, :property => property, :value => value, :unit => unit, :experiment => experiment)
          end

        end
      end

    end

    redirect_to :action => :index
    
  end

=begin
  def solvent(compound)

    solvents = {
      "1-Chloro-2,4-dinitrobenzene" => {
        :solvent => 'DMSO',
        :concentration => 0.1},
      "Salicylic acid" => {
        :solvent => 'DMSO',
        :concentration => 0.1},
      "Eugenol" => {
        :solvent => 'DMSO',
        :concentration => 0.2},
      "Oxazolone" => {
        :solvent => 'DMSO',
        :concentration => 0.2},
      "2-Mercaptobenzothiazolone (MBT)" => {
        :solvent => 'DMSO',
        :concentration => 0.2},
      "Diethyl Phthalate" => {
        :solvent => 'DMSO',
        :concentration => 0.2},
      "Octanoic acid" => {
        :solvent => 'DMSO',
        :concentration => 0.2},
      "Cinnamic Aldehyde" => { :solvent => nil },
      "Sodium lauryl sulphate" => { :solvent => nil },
      "Glyoxal" => { :solvent => nil },
      "Glycerol" => { :solvent => nil },
      "Lactic Acid" => { :solvent => nil }
    }

    if solvents[compound.name][:solvent].nil?
      nil
    else
      unit = Unit.find_by_name("% vol/vol")
      conc = Concentration.find_by_value_and_unit_id(solvents[compound.name][:concentration],unit.id)
      dmso = Compound.find_by_name('DMSO')
      Solvent.find_by_compound_id_and_concentration_id(dmso,conc)
    end

  end
=end

end
