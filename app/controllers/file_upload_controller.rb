require 'roo'

class FileUploadController <  ActionController::Base

  layout 'sensitiv'

  def index
  end

  def new

    flash[:warning] = "You did not send an Excel file" unless params[:file].content_type == 'application/vnd.ms-excel'
    flash[:notice] = "#{params[:file].original_filename} uploaded"
    tmp_excel = RAILS_ROOT+'/tmp/'+params[:file].original_filename
    File.mv(params[:file].path,tmp_excel)
    @xl = Excel.new(tmp_excel)
    @xl.default_sheet = @xl.sheets.first

    measurements = {

      24 => {
        "% cell death" =>  9, # duration => row
        "IgG1-F raw data" => 25,
        "CD86-F raw data" => 26,
        "IgG1-F % positive cells" => 40,
        "CD86-F % positive cells" => 41,
        "CXCL8 Production" => 58,
      },

      48 => {
        "% cell death" => 14,
        "IgG1-F raw data" => 31,
        "CD86-F raw data" => 32,
        "IgG1-F % positive cells" => 46,
        "CD86-F % positive cells" => 47,
        "CXCL8 Production" => 63
      }

    }

    measurements_sheet2 = {

      24 => { "CD86-F raw data (CD86 positive cells)" => 9 },
      48 => { "CD86-F raw data (CD86 positive cells)" => 14 }

    }

    percent = Unit.create(:name => '%') unless percent = Unit.find_by_name('%')
    pg_ml = Unit.create(:name => 'pg/mL') unless pg_ml = Unit.find_by_name('pg/mL')
    properties = {}
    units = {}
    { "% cell death" => ["cell death", percent],
      "IgG1-F raw data" => ["IgG1-F raw data", nil],
      "CD86-F raw data" => ["CD86-F raw data", nil],
      "IgG1-F % positive cells" => ["IgG1-F", percent],
      "CD86-F % positive cells" => ["CD86-F", percent],
      "CXCL8 Production" => ["CXCL8 Production", pg_ml],
      "CD86-F raw data (CD86 positive cells)" => ["CD86-F raw data (CD86 positive cells)", nil] }.each do |p,a|
      properties[p] = Property.create(:name => a[0]) unless properties[p] = Property.find_by_name(a[0])
      units[p] = a[1]
    end

    controls = {

      "medium" => ['B','C'],
      "LPS" => ['D','E'], 
      "0.1% DMSO" => ['F','G']

    }

    compounds = {

      "DNCB" => {
        :compound => Compound.find(203),
        :start_column => 12 # L
      },

      "Cinnamaldehyde" => {
        :compound => Compound.find(9),
        :start_column => 12+8 # 'T'
      },

      "SDS" => {
        :compound => Compound.find(124),
        :start_column => 12+2*8 # 'AB'
      },

      "Salicylic acid" => {
        :compound => Compound.find(12),
        :start_column => 12+3*8 # 'AJ'
      }

    }

    experiment = Experiment.create(:name => "test", :title => 'test', :workpackage => Workpackage.find_by_nr(8)) # complete
    cell_line = CellLine.create(:name => "THP-1") unless cell_line = CellLine.find_by_name("THP-1")
    cell_type = CellType.create(:name => "acute monocytic leukemia")  unless cell_type = CellType.find_by_name("acute monocytic leukemia")
    cd86_type = CellType.create(:name => "CD86 positive THP-1 cells")  unless cell_type = CellType.find_by_name("acute monocytic leukemia")
    organism = Organism.find_by_name("human")
    organism_part = OrganismPart.find_by_name("blood")
    sex = Sex.find_by_name("male")
    hours = Unit.find_by_name("hours")

    dmso = Compound.find(225)
    dmso_concentration = GenericData.create(:experiment => experiment, :value => FloatValue.create(:value => 0.1), :unit => Unit.find_by_name("% vol/vol"), :property => Property.find_by_name("concentration")) 
    lps = Compound.new(:name => "Lipopolysaccharide") unless lps = Compound.find_by_name("Lipopolysaccharide")

    concentration_row = 7 

    durations = {
      24 => GenericData.create(:value => FloatValue.create(:value => 24), :unit => hours, :experiment => experiment),
      48 => GenericData.create(:value => FloatValue.create(:value => 48), :unit => hours, :experiment => experiment)
    }

    Property.create(:name => "concentration") unless Property.find_by_name("concentration")
    growth_condition =  @xl.cell(66,'F').to_s + " cells/well seeded"
    
    id = 1

    controls.each do |n,columns|
      columns.each do |column|
        measurements.each do |t,m|
          # first sheet
          b = BioSample.create(:name => id.to_s, :experiment => experiment, :cell_line => cell_line, :cell_type => cell_type, :organism => organism, :organism_part => organism_part, :sex => sex, :growth_condition => growth_condition)
          id += 1
          treatment = nil
          case n
          when "medium" 
            treatment = Treatment.create(:experiment => experiment, :bio_sample => b, :duration => durations[t] ) 
          when "LPS" 
            treatment = Treatment.create(:experiment => experiment, :bio_sample => b, :duration => durations[t], :solvent => dmso, :solvent_concentration => dmso_concentration, :compound => lps )
          when "0.1% DMSO"
            treatment = Treatment.create(:experiment => experiment, :bio_sample => b, :duration => durations[t], :solvent => dmso, :solvent_concentration => dmso_concentration ) 
          end
          m.each do |p,row|
            value = FloatValue.create(:value => @xl.cell(column,row).to_f)
            d = GenericData.create(:experiment => experiment, :value => value, :property => properties[p], :unit => units[p], :sample => treatment) if treatment # add unit 
          end
          # second sheet
          @xl.default_sheet = @xl.sheets[1]
          measurements_sheet2[t].each do |p,row|
            value = FloatValue.create(:value => @xl.cell(column,row).to_f)
            d = GenericData.create(:experiment => experiment, :value => value, :property => properties[p], :unit => units[p], :sample => treatment) if treatment # add unit 
          end
          @xl.default_sheet = @xl.sheets.first
        end
      end
    end

    compounds.each do |n,c|

      c[:compound].experiments << experiment

      4.times do |i| # concentrations

        concentration_column = c[:start_column] + 2*i
        concentration_value = @xl.cell(concentration_row, concentration_column)
        concentration = GenericData.create(:experiment => experiment, :value => FloatValue.create(:value => concentration_value.to_f), :property => Property.find_by_name("concentration"), :unit => Unit.find_by_name("mM")) 

        2.times do |j| # replicates
          measurement_column = c[:start_column] + 2*i + j
          measurements.each do |t,m|
            b = BioSample.create(:name => id.to_s, :experiment => experiment, :cell_line => cell_line, :cell_type => cell_type, :organism => organism, :organism_part => organism_part, :sex => sex, :growth_condition => growth_condition)
            id += 1
            treatment = Treatment.create(:experiment => experiment, :bio_sample => b, :duration => durations[t], :dose => concentration, :compound => c[:compound], :solvent => dmso, :solvent_concentration => dmso_concentration ) 
            m.each do |p,row|
              value = FloatValue.create(:value => @xl.cell(row,measurement_column).to_f)
              d = GenericData.create(:experiment => experiment, :property => properties[p], :value => value, :unit => units[p], :sample => treatment)
            end
            # second sheet
            @xl.default_sheet = @xl.sheets[1]
            measurements_sheet2[t].each do |p,row|
              value = FloatValue.create(:value => @xl.cell(row,measurement_column).to_f)
              d = GenericData.create(:experiment => experiment, :property => properties[p], :value => value, :unit => units[p], :sample => treatment)
            end
            @xl.default_sheet = @xl.sheets.first
          end
        end
      end

    end

    redirect_to :controller => :experiments, :action => :index
    
  end

end
