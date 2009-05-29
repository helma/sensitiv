require "rinruby"

class File
  def original_filename
    File.basename(path)
  end
  def size
    File.size(path)
  end
  def local_path
    path
  end
end

class RingTrial < ActiveRecord::Base

  has_many :experiments
  file_column :dose_response_curves
  file_column :control_dose_response_curves

  def create_plots

    puts "Searching for treatments ..."
    treatments = []
    self.experiments.each do |e|
      e.treatments.each do |t|
        treatments << t
      end
    end
    cell_line = treatments.collect{|t| t.bio_sample.cell_line.name}.uniq.join(', ')
    duration = treatments.collect{|t| t.duration.value}.uniq.join(', ')
    puts "Updating attributes ..."
    self.update_attribute( :name, cell_line + " (" + duration + " hours)")
    self.update_attribute(:endpoint_names, treatments.collect{|t| t.outcomes.collect{|o| o.property.name}}.flatten.compact.uniq.sort.join(', '))
    self.update_attribute(:compound_names, treatments.collect{|t| t.compound.name if t.compound and !t.compound.name.match(/Medium|Lipopolysaccharide|DMSO/) }.compact.uniq.sort.join(', '))

  #create_dose_response_curves
    
    compound_table = File.open("#{RAILS_ROOT}/tmp/compounds.tab","w+")
    control_table = File.open("#{RAILS_ROOT}/tmp/controls.tab","w+")
    compound_table.puts "Partners\tcompounds\tendpoints\tconcentrations\tvalues"
    control_table.puts "Partners\tcompounds\tendpoints\tvalues"
    puts "Searching for outcomes ..."
    treatments.collect{|t| t.outcomes}.flatten.uniq.each do |o|
      property_name = o.property.name
      property_name += " [#{o.unit.name}]" if o.unit
      if o.treatment.compound and !o.treatment.compound.name.match(/Medium|Lipopolysaccharide|DMSO/)
        compound_table.puts [
          o.treatment.experiment.people.collect{|p| p.organisation.name}.flatten.uniq.join(', '),
          o.treatment.compound.name + ' [' + o.treatment.concentration.unit.name + ']',
          property_name,
          o.treatment.concentration.value,
          o.value.value
        ].join("\t")
      else
        control_table.puts [
          o.treatment.experiment.people.collect{|p| p.organisation.name}.flatten.uniq.join(', '),
          o.treatment.compound.name,
          property_name,
          o.value.value
        ].join("\t")
      end
    end
    compound_table.close
    control_table.close


    puts "Creating R data frame ..."
    tmp_compounds = "#{RAILS_ROOT}/tmp/compounds.pdf"
    R.eval "library('ggplot2')"
    R.eval "data <- read.delim('#{RAILS_ROOT}/tmp/compounds.tab')"
    R.eval "data$endpoints <- factor(data$endpoints, levels=c('Cell survival [%]', 'CD86 RFI' ,'CD86 positive cells [%]', 'CD86 stimulation index', 'CXCL8 relative production [pg/mL/10^6 cells]'))"

    puts "Calculating significances ..."
    R.eval "sig = by(data,list(data$Partners,data$compounds,data$endpoints),function(x) kruskal.test(values ~ concentrations , data = x)$p.value) < 0.05"
    R.eval "data$Significance = lapply(row.names(data), function(x) if (sig[data[x,1],data[x,2],data[x,3]]) return('p < 0.05') else return('p > 0.05'))"
    R.eval "data$Significance = factor(as.character(data$Significance))"

    puts "Creating plots ..."
    R.eval "pdf('#{tmp_compounds}', width = 12, height = 8, paper = 'a4r')"
    R.eval "qplot(concentrations, values, data = data, geom = c('point','smooth'), colour = Significance, shape = Partners, main = '#{self.name}', ylab = '', xlab = '', log = 'y')  + facet_grid(endpoints ~ compounds, scales = 'free') + theme_set(theme_grey(base_size = 7))"
    R.eval "dev.off()"

    puts "Creating R data frame for controls ..."
    tmp_controls = "#{RAILS_ROOT}/tmp/controls.pdf"
    R.eval "data <- read.delim('#{RAILS_ROOT}/tmp/controls.tab')"
    R.eval "data$endpoints <- factor(data$endpoints, levels=c('Cell survival [%]', 'CD86 RFI' ,'CD86 positive cells [%]', 'CD86 stimulation index', 'CXCL8 relative production [pg/mL/10^6 cells]'))"
    R.eval "data$compounds <- factor(data$compounds, levels=c('Medium', 'DMSO' ,'Lipopolysaccharide (LPS)'))"

    puts "Calculating DMSO significances ..."
    R.eval "dmso_sig = by(data,list(data$Partners,data$endpoints), function(x) wilcox.test(x$values[x['compounds'] == 'Medium'],x$values[x['compounds'] == 'DMSO'])$p.value < 0.05)"

    puts "Calculating LPS significances ..."
    R.eval "lps_sig = by(data,list(data$Partners,data$endpoints), function(x) if (length(x$values[x['compounds'] == 'Lipopolysaccharide (LPS)']) > 0) return(wilcox.test(x$values[x['compounds'] == 'Medium'],x$values[x['compounds'] == 'Lipopolysaccharide (LPS)'])$p.value < 0.05) else return(FALSE))"

    puts "Attaching significances to data frame ..."
    R.eval "data$Significance = lapply(row.names(data), function(x) if ((data[x,'compounds'] == 'DMSO' & dmso_sig[data[x,'Partners'],data[x,'endpoints']]) | (data[x,'compounds'] == 'Lipopolysaccharide (LPS)' & lps_sig[data[x,'Partners'],data[x,'endpoints']])) 'p < 0.05' else 'p > 0.05')"
    R.eval "data$Significance = factor(as.character(data$Significance))"

    puts "Creating control plots ..."
    R.eval "pdf('#{tmp_controls}', height = 10, width = 8, paper = 'a4')"
    R.eval "qplot(0,values, data = data, geom = 'point', colour = Significance, shape = Partners, main = 'Controls for #{self.name}', ylab = '', xlab = '') + stat_summary(fun.y = 'median', shape = c(1,2), size = 4, geom = 'point') + facet_grid(endpoints ~ compounds , scales = 'free') + theme_set(theme_grey(base_size = 7))"
    #R.eval "qplot(compounds, values, data = data, geom = c('point'), colour = Significance, shape = Partners, main = 'Controls for #{self.name}', ylab = '', xlab = '', log = 'y') + stat_summary(fun.y = 'mean', colour='black', geom=geom, size = 3) + facet_grid(endpoints ~ . , scales = 'free') + theme_set(theme_grey(base_size = 7))"
    R.eval "dev.off()"

    puts "Saving pdf files ..."
    file = File.open(tmp_compounds)
    self.update_attribute(:dose_response_curves , file)
    file.close
    file = File.open(tmp_controls)
    self.update_attribute(:control_dose_response_curves , file)
    file.close
  end

end
