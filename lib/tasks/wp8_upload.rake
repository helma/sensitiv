require 'roo'
require 'fileutils'

namespace "wp8" do

  desc "Import WP8 Excel sheets"
  task :import => :environment do

    wp = Workpackage.find_by_nr(8)
    RingTrial.find(:all).each do |rt|
      rt.name = rt.name + " (preliminary)"
      rt.save
    end
    Dir["#{RAILS_ROOT}/wp8/*.xls"].sort.each do |file|
      # upload sheet
      puts file
      data = parse(Excel.new(file))

      ring_trial = RingTrial.find_or_create_by_name("#{data[:cell_line]} (#{data[:treatment_time]} hours)")
      puts "Ring trial #"+ring_trial.name

      experiment = Experiment.create(
        :name => File.basename(file),
        :title => "Exposure of #{data[:cell_line]} cells",
        :description => "#{data[:cell_line]} cells were exposed to increasing concentrations of test compounds. After 24 hours cell viability, CD86 expression and IL-8 production were determined. [Experiment Nr. " + data[:experiment][:number].to_s + "]",
        :workpackage => wp,
        :ring_trial => ring_trial,
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
        solvent = Solvent.find_or_create_by_compound_id_and_concentration_id(dmso,solvent_concentration)
      end

      Result.create :workpackage => wp, :person => person, :file => File.new(file), :name => experiment.title, :description => experiment.description

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

        neg_control_concentration = Concentration.find_or_create_by_value_and_unit_id(0, conc_unit.id)
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
          if solvent.nil? # create negative controls
            data[:compound_ids].each do |id|
              compound = Compound.find(id)
              negative_controls << Treatment.create(:compound => compound, :duration => duration, :bio_sample => bio_sample, :concentration => neg_control_concentration, :solvent => solvent, :experiment => experiment)
            end
          end
        when 'LPS'
          compound = Compound.find_by_name("Lipopolysaccharide (LPS)")
          treatment = Treatment.create(:compound => compound, :duration => duration, :bio_sample => bio_sample, :experiment => experiment)
        when /DMSO/
          unless solvent.nil? # create negative controls
            treatment = Treatment.create(:duration => duration, :bio_sample => bio_sample, :compound => solvent.compound, :concentration => solvent.concentration, :experiment => experiment) 
            data[:compound_ids].each do |id|
              compound = Compound.find(id)
            end
          end
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
    end
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

def parse(xl)

  # define layout of excel sheet here
  # cell arguments: row, column, sheet

  # read single cells
  
  # first sheet
  xl.default_sheet = xl.sheets[0]

  data = {
    :experiment => {
      :number => xl.cell(2,2),
      :ring_trial => xl.cell(3,2),
    },
    :submitter => xl.cell(5,2),
  }

  # second sheet
  xl.default_sheet = xl.sheets[1]
  data[:cell_line] = xl.cell(1,3)
  data[:treatment_time] = xl.cell(2,3)
  data[:solvent_concentration] = xl.cell(8,7)

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
  data[:compound_ids] = []
  col = ranges[:compounds][:start_column]
  ranges[:compounds][:nr].times do
    name = xl.cell(ranges[:compounds][:row],col)
    data[:compound_ids] << name.sub(/.*\[id: (\d+)\]/,'\1').to_i if name.match(/id:/)
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
