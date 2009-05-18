#require 'rsruby'
class DataAnalysisController < ApplicationController

  def index

    create_dose_response_curves if request.post?
    @dose_response_pages = DoseResponseCurve.find(:all).collect{|dr| [dr.cell_line.name, dr.duration.name]}

  end

  def show_all
    experiments = Experiment.find_all_by_workpackage_id(8)
    treatments = experiments.collect{|e| e.treatments}.flatten.compact
    @compounds = treatments.collect{|t| t.compound}.uniq.compact
    cell_lines = treatments.collect{|t| t.bio_sample.cell_line}.uniq.compact
    properties = treatments.collect{|t| t.measurements}.flatten.compact.collect{|m| m.property}.uniq

    @images = {}
    cell_lines.each do |cell_line|
      @images[cell_line] = {}
      properties.each do |property|
        @images[cell_line][property] = {}
        @compounds.each do |compound|
          @images[cell_line][property][compound] = "graphs/#{cell_line.name}_#{property.name}_#{compound.name}.png" if compound.training_compound
        end
      end
    end
    #puts "*#{request.post?}*"

  end

  def create_dose_response_curves

    experiments = Experiment.find_all_by_workpackage_id(8)
    treatments = experiments.collect{|e| e.treatments}.flatten.compact
    compounds = treatments.collect{|t| t.compound}.uniq.compact
    cell_lines = treatments.collect{|t| t.bio_sample.cell_line}.uniq.compact
    properties = treatments.collect{|t| t.measurements}.flatten.compact.collect{|m| m.property}.uniq
    durations = treatments.collect{|t| t.duration}.flatten.compact

    cell_lines.each do |cell_line|
      durations.each do |duration|
        properties.each do |property|
          compounds.each do |compound|
            dose_response_curve(cell_line,duration,property,compound) if compound.training_compound
          end
        end
      end
    end

    redirect_to :action => :index

  end

  def show

    workpackage = Workpackage.find(8)
    compound = Compound.find(params[:compound_id])
    cell_line = CellLine.find_by_name(params[:cell_line])
    property = Property.find_by_name(params[:property])

  end

  private 

  def dose_response_curve(cell_line,duration,property,compound)

    treatments = Treatment.find_all_by_compound_id(compound.id).collect{|t| t if t.bio_sample and t.bio_sample.cell_line == cell_line}
    concentrations = []
    concentration_unit = treatments.collect{|t| t.concentration.unit.name if t and t.concentration}.uniq.compact.first
    responses = []
    response_unit = property.outcomes.collect{|o| o.unit.name if o.unit}.uniq.compact.first
    concentration_values = treatments.collect{|t| t.concentration.value if t and t.concentration}.uniq.compact
    concentration_values.each do |conc_val|
      unless conc_val.nil?
        conc_measurements = treatments.collect{|t| t.measurements if t and t.concentration.value == conc_val}.flatten.uniq.compact
        results = conc_measurements.collect{|m| m.value.value if m and m.property == property}.uniq.compact
        results.each do |r|
          unless r.nil? or conc_val.nil?
            concentrations << conc_val
            responses << r
          end
        end
      end
    end

    filename = "#{RAILS_ROOT}/public/images/graphs/#{cell_line.name}_#{duration.name}_#{property.name}_#{compound.name}.png"

    begin
      r = RSRuby.instance
      r.require("ggplot2")
      r.png(filename = filename, width = 200, height = 200)
=begin
      r.plot({'x' => concentrations,
              'y' => responses,
              #'main' => compound.name,
              'xlab' => "Concentration [#{concentration_unit}]",
              'ylab' => "#{property.name} [#{response_unit}]"
      })
=end
      r.qplot({'x' => concentrations,
              'y' => responses,
              'main' => compound.name,
              'xlab' => "Concentration [#{concentration_unit}]",
              'ylab' => "#{property.name} [#{response_unit}]"
      })
      r.dev_off.call
    rescue
      puts "error plotting r.plot({'x' => #{concentrations},
            'y' => #{responses},
            'main' => #{compound.name},
            'xlab' => Concentration [#{concentration_unit}],
            'ylab' => #{property.name} [#{response_unit}] })"
    end

    sheet = DoseResponseSheet.create(:cell_line => cell_line,:duration => duration) unless sheet = DoseResponseSheet.find_by_cell_line_and_duration(cell_line,duration)

    curve = DoseResponseCurve.create(:compound => compound, :property => property, :cell_line => cell_line, :duration => duration, :image => File.open(filename))
    #sheet.dose_response_curves << curve
    #sheet.save

  end

end
