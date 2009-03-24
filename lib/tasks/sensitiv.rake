namespace "sensitiv" do

  desc "Copy production database from Sensitiv server"
  task :copy_production_db do
    sh "rsync -avz sens-it-iv.fdm.uni-freiburg.de:/var/www/sensitiv-production/db/production.sqlite3 db/"
  end

  desc "Copy file documents from Sensitiv server"
  task :copy_file_documents do
    sh "rsync -avz --delete sens-it-iv.fdm.uni-freiburg.de:/var/www/sensitiv-production/public/file_document/ public/file_document/"
    sh "rsync -avz --delete sens-it-iv.fdm.uni-freiburg.de:/var/www/sensitiv-production/public/protocol/ public/protocol/"
  end

  desc "Sync development database with current production database"
  task "db:development:sync" => [:copy_production_db, :copy_file_documents] do
    sh "cp db/production.sqlite3 db/development.sqlite3"
  end

  desc "Sync production database with current production database"
  task "db:production:sync" => [:copy_production_db, :copy_file_documents]

end

namespace :affy do

  desc "Import, normalize and filter Affimetrix CEL files"
  task :import => :environment do

    load(RAILS_ROOT+"/vendor/plugins/opentox/app/models/dags_object.rb")
    load(RAILS_ROOT+"/vendor/plugins/opentox/app/models/inputs_output.rb")
    ENV['R_HOME'] = '/usr/lib/R'

    r = RSRuby.instance
    r.library('affy')
    r.library('genefilter')

    filenames = ''
    file_docs = FileDocument.find(:all)
    file_docs.each do |f|
      if f.file.match(/\.CEL/)
        if filenames == ''
          filenames = '"' + f.file.gsub(/\/home\/ch\/sensitiv\/config\/\.\.\//,'') +'"'
        else
          filenames = filenames + ',"' + f.file.gsub(/\/home\/ch\/sensitiv\/config\/\.\.\//,'') + '"'
        end
      end
    end

    #puts filenames
    r.eval_R("eset <- justRMA(#{filenames})")

    pheno = File.new("#{RAILS_ROOT}/tmp/pheno.txt","w")
    #puts pheno.path
    BioSample.find(1).attributes.each do |c,v|
      pheno.print "\t\"#{c.gsub(/_id/,"").underscore}\""
    end
    pheno.print "\n"

    file_docs = FileDocument.find(:all)
    biosamples = Array.new
    file_docs.each do |f|
      if f.file.match(/\.CEL/)
        puts "#{f.file} has #{f.inputs.size} inputs!" if f.inputs.size > 1
        f.inputs.each do |i|
          if i.class == BioSample

            pheno.print "\"#{File.basename(f.file)}\""

            i.attributes.each do |n,v|
              if v.blank?
                pheno.print "\t\"NA\""
              elsif n.match(/_id/)
                n = n.gsub(/_id/,"")
                value = n.classify.constantize.find(v).name
                pheno.print "\t\"#{value}\""
              else
                pheno.print "\t\"#{v}\""
              end
            end
            pheno.print "\n"
          end
        end
      end
    end

    p = pheno.path
    call = "\"phenoData(eset) <- read.phenoData('"+pheno.path+"')\""
    #puts call
    r.eval_R(call)

    # prefilter
    # 1. at least 20% of the samples have a measured intensity of at least 100
    # 2. coefficient of variation of intensities across samples between 0.7 and 10
    # values from MTPALL.pdf

    r.eval_R("X <- exprs(eset)")
    r.eval_R("ffun <- filterfun(pOverA(p=0.2,A=100),cv(a=0.7,b=10))")
    r.eval_R("filt <- genefilter(2^X,ffun)")
    r.eval_R("filtALL <- eset[filt,]")
    r.eval_R("save(filtALL,file='tmp/all-filtered.R')")

  end

end
