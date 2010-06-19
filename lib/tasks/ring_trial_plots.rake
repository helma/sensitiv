require 'rinruby'

namespace "wp8" do

  desc "Create ring trial dose-response tables"
  task :dose_response_table => :environment do
    RingTrial.find(:all).each do |rt|
      
      endpoints = []
      compounds = []

      puts "Ring trial " + rt.name
      puts "Searching for experiments ..."
      compound_table = File.open("#{RAILS_ROOT}/tmp/rt#{rt.id}-compounds.tab","w+")
      compound_table.puts "Partners\tcompounds\tendpoints\tconcentrations\tvalues"

      rt.experiments.each do |e|
        puts e.name
        e.treatments.collect{|t| t unless t.compound.name.match(/Medium|Lipopolysaccharide|DMSO/)}.compact.each do |t|
          partner = t.experiment.people.collect{|p| p.organisation.name}.flatten.uniq.join(', ')
          compound = t.compound.name.sub(/2-Mercaptobenzothiazolone \(MBT\)/,'MBT') + ' [' + t.concentration.unit.name + ']'
          compounds << t.compound.name
          outcomes = {}
          t.outcomes.each do |o|
            property_name = o.property.name.sub(/CXCL8 relative production/,'CXCL8') # shorten CXCL8 relative production 
            endpoints << o.property.name
            property_name += " [#{o.unit.name}]" if o.unit
            outcomes[property_name] = o.value.value
          end
          if outcomes["Cell survival [%]"]
            outcomes.each do |p,v|
              data = nil
              case p
              when /Cell survival/
                data = [ partner, compound, p, t.concentration.value, v ]
              else
                data = [ partner, compound, p, t.concentration.value, 100*v/outcomes["Cell survival [%]"] ] # normalize by cell survival
              end
              compound_table.puts data.join("\t") unless data.last == 0 # ignore unavailable (==0) values
              puts data.join("\t") + " ignored" if data.last == 0 
            end
          else
            puts "Ignored:"
            puts "\t"+partner
            puts "\t"+compound
            puts "\t"+t.concentration.value.to_s
            puts outcomes.to_yaml
          end
        end

        puts "Adding negative controls ..."
        e.treatments.collect{|t| t.compound.name.sub(/2-Mercaptobenzothiazolone \(MBT\)/,'MBT') + ' [' + t.concentration.unit.name + ']' unless t.compound.name.match(/Medium|Lipopolysaccharide|DMSO/)}.compact.uniq.each do |compound|
          e.treatments.collect{|t| t if t.compound.name.match(/DMSO/)}.compact.each do |t|
            partner = t.experiment.people.collect{|p| p.organisation.name}.flatten.uniq.join(', ')
            outcomes = {}
            t.outcomes.each do |o|
              property_name = o.property.name.sub(/CXCL8 relative production/,'CXCL8') # shorten CXCL8 relative production 
              property_name += " [#{o.unit.name}]" if o.unit
              outcomes[property_name] = o.value.value
            end
            if outcomes["Cell survival [%]"]
              outcomes.each do |p,v|
                data = nil
                case p
                when /Cell survival/
                  data = [ partner, compound, p, 0, v ]
                else
                  data = [ partner, compound, p, 0, 100*v/outcomes["Cell survival [%]"] ] # normalize by cell survival
                end
                compound_table.puts data.join("\t") unless data.last == 0 # ignore unavailable (==0) values
                puts data.join("\t") + " ignored" if data.last == 0 
              end
            else
              puts "Ignored:"
              puts "\t"+partner
              puts "\t"+compound
              puts "\t0"
              puts outcomes.to_yaml
            end
          end
        end
      end

      puts "Updating attributes ..."
      rt.update_attribute(:endpoint_names, endpoints.uniq.sort.join(', '))
      rt.update_attribute(:compound_names, compounds.uniq.sort.join(', '))

      compound_table.close
    end

  end

  desc "Create ring trial dose-response plots"
  task :dose_response => :environment do
    R.eval "library('ggplot2')"
    RingTrial.find(:all).each do |rt|

      puts "Ring trial " + rt.name
      puts "Creating R data frame ..."
      tmp_compounds = "#{RAILS_ROOT}/tmp/rt#{rt.id}-compounds.pdf"
      R.eval "data <- read.delim('#{RAILS_ROOT}/tmp/rt#{rt.id}-compounds.tab')"
      R.eval "data$endpoints <- factor(data$endpoints, levels=c('Cell survival [%]', 'CD86 RFI' ,'CD86 positive cells [%]', 'CD86 stimulation index', 'CXCL8 [pg/mL/10^6 cells]'))"

      puts "Calculating significances ..."
      R.eval "sig = by(data,list(data$Partners,data$compounds,data$endpoints),function(x) try(kruskal.test(values ~ concentrations , data = x)$p.value)) < 0.05"
      R.eval "data$Significance = lapply(row.names(data), function(x) if (sig[data[x,1],data[x,2],data[x,3]]) return('p < 0.05') else return('p > 0.05'))"
      R.eval "data$Significance = factor(as.character(data$Significance))"

      puts "Creating plots ..."
      R.eval "pdf('#{tmp_compounds}', width = 12, height = 8, paper = 'a4r')"
      R.eval "qplot(concentrations, values, data = data, geom = c('point','smooth'), colour = Significance, shape = Partners, main = '#{rt.name}', ylab = '', xlab = '', log = 'y')  + facet_grid(endpoints ~ compounds, scales = 'free') + theme_set(theme_grey(base_size = 7))"
      R.eval "dev.off()"
      puts "Saving pdf files ..."
      file = File.open(tmp_compounds)
      rt.update_attribute(:dose_response_curves , file)
      file.close

    end

  end

  desc "Create ring trial control plots"
  task :control_table => :environment do
    RingTrial.find(:all).each do |rt|

      control_table = File.open("#{RAILS_ROOT}/tmp/rt#{rt.id}-controls.tab","w+")
      control_table.puts "Partners\tcompounds\tendpoints\tvalues"

      rt.experiments.each do |e|
        puts e.name
        puts "Adding controls ..."
        e.treatments.collect{|t| t if t.compound.name.match(/Medium|Lipopolysaccharide|DMSO/)}.compact.each do |t|
          t.outcomes.each do |o|
            property_name = o.property.name.sub(/CXCL8 relative production/,'CXCL8') # shorten CXCL8 relative production 
            property_name += " [#{o.unit.name}]" if o.unit
            control_table.puts [
              t.experiment.people.collect{|p| p.organisation.name}.flatten.uniq.join(', '),
              t.compound.name,
              property_name,
              o.value.value
            ].join("\t")
          end
        end
      end
      control_table.close
    end
  end


  desc "Create ring trial control plots"
  task :control => :environment do
    R.eval "library('ggplot2')"
    RingTrial.find(:all).each do |rt|
      puts "Creating R data frame for controls ..."
      tmp_controls = "#{RAILS_ROOT}/tmp/rt#{rt.id}-controls.pdf"
      R.eval "data <- read.delim('#{RAILS_ROOT}/tmp/rt#{rt.id}-controls.tab')"
      R.eval "data$endpoints <- factor(data$endpoints, levels=c('Cell survival [%]', 'CD86 RFI' ,'CD86 positive cells [%]', 'CD86 stimulation index', 'CXCL8 [pg/mL/10^6 cells]'))"
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
      R.eval "qplot(0,values, data = data, geom = 'point', colour = Significance, shape = Partners, main = 'Controls for #{rt.name}', ylab = '', xlab = '', log = 'y') + stat_summary(fun.y = 'median', colour='black', size = 3, geom = 'point') + facet_grid(endpoints ~ compounds , scales = 'free') + theme_set(theme_grey(base_size = 7))"
      R.eval "dev.off()"
      puts "Saving pdf files ..."
      file = File.open(tmp_controls)
      rt.update_attribute(:control_dose_response_curves , file)
      file.close
    end
  end

end
