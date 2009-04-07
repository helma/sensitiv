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

      :person => {
        :first_name => xl.cell(7,2),
        :last_name => xl.cell(8,2),
        :email => xl.cell(9,2),
        :phone => xl.cell(10,2)
      },

      :organisation => {
        :name => xl.cell(13,2),
        :address => xl.cell(14,2)
      }
    }

    # second sheet
    xl.default_sheet = xl.sheets[1]
    data[:cell_line] = xl.cell(1,3),
    data[:treatment_time] = xl.cell(2,3),
    #data[:concentration_unit]  = xl.cell(2,3)

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
        :start_column => 12, # 'L'
        :nr_columns => 4
      },

      :concentrations => {
        :row => 8,
        :nr => 5,
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
    ranges[:compounds][:nr_columns].times do
      name = xl.cell(ranges[:compounds][:row],col)
      conc_unit = xl.cell(ranges[:compounds][:row],col+9)
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

    organisation = Organisation.create(
      :name => data[:organisation][:name],
      :address => data[:organisation][:address]
    ) unless organisation = Organisation.find_by_name(data[:organisation][:name])

    person = Person.create(
      :first_name => data[:person][:first_name], 
      :last_name => data[:person][:last_name], 
      :email => data[:person][:email],
      :phone => data[:person][:phone],
      :organisation => organisation
    ) unless person = Person.find_by_email(data[:person][:email])

    person.experiments << experiment
    person.save

    cell_line = CellLine.find_by_name(data[:cell_line])
    organism = Organism.find_by_name('human')
    organism_part = OrganismPart.find_by_name("blood")
    cell_type = CellType.find_by_name("acute myelomonocytic leukemia")
    sex = Sex.find_by_name("male")

    duration = Duration.find_by_value_and_unit_id(data[:treatment_time],Unit.find_by_name("hours").id)

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

      concentration = Concentration.create(:value => t[:concentration], :unit => conc_unit) unless concentration = Concentration.find_by_value_and_unit_id(t[:concentration], conc_unit.id)
      treatment = nil

      case t[:compound]
      when /id:/
        compound_id = t[:compound].sub(/.*\[id: (\d+)\]/,'\1').to_i
        compound = Compound.find(compound_id)
        treatment = Treatment.create(:compound => compound, :duration => duration, :bio_sample => bio_sample, :concentration => concentration, :experiment => experiment)
      when "medium"
        compound = Compound.find_by_name("Medium")
        treatment = Treatment.create(:compound => compound, :duration => duration, :bio_sample => bio_sample, :experiment => experiment)
      when 'LPS'
        compound = Compound.find_by_name("Lipopolysaccharide (LPS)")
        treatment = Treatment.create(:compound => compound, :duration => duration, :bio_sample => bio_sample, :experiment => experiment)
      when /DMSO/
        solvent = Solvent.find(10)
        treatment = Treatment.create(:duration => duration, :bio_sample => bio_sample, :solvent => solvent, :experiment => experiment)
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

end
