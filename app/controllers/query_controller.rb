class QueryController < ApplicationController


  def form
    @columns = [ "organism_id", "organism_part_id", "sex_id", "strain_or_line_id","individual_name", "developmental_stage_id", "cell_line_id", "cell_type_id", "growth_condition"]
    @properties = [ Organism, OrganismPart, Sex, StrainOrLine, DevelopmentalStage, CellLine, CellType, "individual_name", "growth_condition"]#
    @options = Hash.new
    @selection = Hash.new
    @selection["A"] = Hash.new
    @selection["B"] = Hash.new
    @properties.each do |c|
      case c
      when /growth_condition|individual_name/ 
        opts = BioSample.find(:all)
        opt_names = Array.new
        opts.each do |o|
          opt_names << o.attributes[c] unless o.attributes[c].blank?
        end
        opt_names << " -- all -- "
        @options[c] = opt_names.uniq.sort
        @selection["A"][c] = " -- all -- "
        @selection["B"][c] = " -- all -- "
      else
        opts = c.find(:all)
        opt_names = Array.new
        opts.each do |o|
          opt_names << o.name
        end
        opt_names << " -- all -- "
        @options[c] = opt_names.sort
        @selection["A"][c] = " -- all -- "
        @selection["B"][c] = " -- all -- "
      end
    end
  end

  def submit

    @properties = Array.new
    @selection = Hash.new
    @selection["A"] = Hash.new
    @selection["B"] = Hash.new

    ["A","B"].each do |g| 
      params[g].each do |p,n|
        if n == " -- all -- " 
          params[g][p] = "NA"
        else
          @selection[g][p] = n
        end
        @properties << p
      end
    end

    @properties.uniq!

    self.differential_gene_expression
    self.subnetwork
    #self.form
    
    @columns = [ "organism_id", "organism_part_id", "sex_id", "strain_or_line_id","individual_name", "developmental_stage_id", "cell_line_id", "cell_type_id", "growth_condition"]
    @properties = [ Organism, OrganismPart, Sex, StrainOrLine, DevelopmentalStage, CellLine, CellType, "individual_name", "growth_condition"]#
    @options = Hash.new
    @properties.each do |c|
      case c
      when /growth_condition|individual_name/ 
        opts = BioSample.find(:all)
        opt_names = Array.new
        opts.each do |o|
          opt_names << o.attributes[c] unless o.attributes[c].blank?
        end
        opt_names << " -- all -- "
        @options[c] = opt_names.uniq.sort
      else
        opts = c.find(:all)
        opt_names = Array.new
        opts.each do |o|
          opt_names << o.name
        end
        opt_names << " -- all -- "
        @options[c] = opt_names.sort
      end
    end
  end

  def differential_gene_expression

    call = "
    library('affy')
    #library('annaffy')
    library('RankProd')
    #library('hgu133plus2')

    load('./vendor/plugins/opentox/lib/R/annotations.R')
    load('./tmp/all-filtered.R')
    phenoData(filtALL) <- read.phenoData('tmp/pheno.txt')

    sample1 <- TRUE
    sample2 <- TRUE
    sample1[1:length(pData(filtALL)[,1])] <- TRUE
    sample2[1:length(pData(filtALL)[,1])] <- TRUE
    "


    # query
    @cols = Array.new
    @properties.each do |p|
      if params["A"][p] != "NA" && params["B"][p] != "NA" 
        call =  call + p.to_s + " <- c(\"" + params["A"][p] + "\",\"" + params["B"][p] + "\")\n"
        @cols << p.to_s
      end
    end

    call = call + "query <- data.frame(cbind("
    n = 0
    @cols.each do |c|
      call = call + ',' unless n == 0
      call = call + c
      n += 1
    end
    call = call + "))"

    call = call + "
    for (cond in names(query)) {
      if (query[cond][1,] != 'NA') {
        sample1 <- sample1 & (pData(filtALL)[cond] == as.vector(query[cond][1,]))
      }
      if (query[cond][2,] != 'NA') {
        sample2 <- sample2 & (pData(filtALL)[cond] == as.vector(query[cond][2,]))
      }
    }

    subset <- sample1 | sample2
    subset <- subset[!is.na(subset)]

    subsetALL <- filtALL[,subset]

    sample2 <- sample2[subset]
    available <- !is.na(sample2)
    sample2 <- sample2[!is.na(sample2)]

    rp <- RP(exprs(subsetALL)[,available], sample2, num.perm = 20, gene.names = geneNames(subsetALL))
    genes <- topGene(rp,cutoff = 0.01, method=\"pval\", gene.names = geneNames(subsetALL))

    table <- rbind(genes$Table1,genes$Table2)
    write.table(table,\"tmp/results.tab\",col.names=F)
    "

    system("rm -f tmp/query.R")
    system("rm -f tmp/results.tab")
    f = File.open("tmp/query.R","w+")
    f.print(call)
    f.close
    `R CMD BATCH --no-save --no-restore tmp/query.R`
    @calls = call.gsub(/\n/,'<p/>')

    @results = Array.new
    File.open("tmp/results.tab").each do |line|
      line.gsub!(/"/,'')
      @results << line.split
    end

  end

  def subnetwork

    dot = "graph G {\n"
    dot << "overlap=false;\n"
    dot << "node [fontsize=8;shape=box];\n"


    gene_names = Hash.new
    relevant_entrez_ids = Array.new
    interactions = Array.new

    @disconnected = Array.new
    ratios = Hash.new
    pfps = Hash.new
    rp = Hash.new
    @results.each do |row|

      annotation = HgU133Plus2Annotation.find_by_probe_set_id(row[0])
      gene_names[annotation.entrez_gene] = annotation.gene_title
      relevant_entrez_ids << annotation.entrez_gene
      interactions = interactions + HumanInteraction.find_all_entrez_ids(annotation.entrez_gene)
      ratios[annotation.entrez_gene] = row[3].to_f
      pfps[annotation.entrez_gene] = row[4].to_f
      rp[annotation.entrez_gene] = row
    end

    relevant_entrez_ids.uniq!
    interactions.uniq!

    interactions.each do |i|
      if i.unique_id_a == i.unique_id_b
        begin
        @disconnected << rp[i.unique_id_a] if pfps[i.unique_id_a] > 0.05
        rescue
        end
      else
        if relevant_entrez_ids.include?(i.unique_id_a) && relevant_entrez_ids.include?(i.unique_id_b)
          line = i.unique_id_a + " -- " + i.unique_id_b +  ";\n"
          dot << line

          #color nodes
          [i.unique_id_a,i.unique_id_b].each do |uid|
            begin
            dot << uid + " [label="+'\"'+gene_names[uid].gsub(/,/,",\\n")+'\"'
            if ratios[uid] < 1
              color = 9*(1 - ratios[uid])
              dot << ",style=filled,colorscheme=greens9,fillcolor=#{color.to_i},URL="+'\"'+'/entrez/'+uid+'\"'+"];\n"
            elsif ratios[uid] > 1
              color = 9*(1 - 1/ratios[uid])
              dot << ",style=filled,colorscheme=reds9,fillcolor=#{color.to_i},URL="+'\"'+'/entrez/'+uid+'\"'+"];\n"
            end
            rescue
            end
          end
        end
      end
    end

    dot << "}\n"

    system("rm -f public/images/neato.png public/images/neato.map")
    call = "echo \"#{dot}\" | tee 'tmp/subgraph.dot' | neato -Tcmapx -o 'public/images/neato.map' -Tpng -o 'public/images/neato.png'"
    system(call)

  end

end
