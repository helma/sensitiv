class CompoundsController < ApplicationController

  require 'rjb'

	active_scaffold :compound do |config|

    # general
    config.actions.exclude :create
    config.actions.exclude :update

    config.action_links.add :list, :label => 'Training compounds', :type => :table, :parameters => {:show => 'training_set'}, :page => true
    config.action_links.add :list, :label => 'All compounds', :type => :table, :parameters => {:show => 'all'}, :page => true
		config.actions.add :show

    config.columns.add :chemid

		config.columns[:cas].label = 'CAS'
		config.columns[:smiles].label = '2D Structure'
		config.columns[:chemid].label = 'External Data'
    config.columns[:training_compound].ui_type = :checkbox

    columns[:cas].set_link('show', :page => true)
    columns[:name].set_link('show', :page => true)

    # list
		config.list.per_page = 15 
		config.list.sorting = {:name => 'ASC'}
		config.list.columns = [:cas, :name]

    # show
    config.show.link.page = true
		show.columns = [:cas, :smiles, :training_compound, :comment, :chemid]#, :datas, :sensitiser

=begin
    # update
    config.update.link.page = true
    config.update.columns = [:name, :cas, :smiles, :training_compound, :comment]

    # create
    config.create.link.page = true
    config.create.columns = [:name, :cas, :smiles, :training_compound, :comment]
=end

	end

  def index
    if params[:id].blank?
      redirect_to :action => 'list'
    else
      redirect_to :action => 'show', :id => params[:id]
    end
  end

  def edit_experiment
		if request.post? # create/update
    else
      @experiment = Experiment.find(params[:experiment_id])
      @compound = Compound.find(params[:id])
      case @experiment.name
      when "llna"
        render :template => 'compounds/llna_form'
      else
        render :template => 'compounds/default_form'
      end
    end
  end

  def validation
    @failed = []
    Compound.find(:all).each do |c|
      failures = ''
      if c.cas.blank?
        failures << "CAS Nr. missing<br/>" 
      else
        failures << "Invalid CAS Nr.<br/>" unless c.cas_valid?
      end
      if c.smiles.blank?
        failures << "Structure missing<br/>" 
      else
        failures << "Invalid Smiles structure<br/>" unless c.smiles_valid?
      end
=begin
      unless c.cas.blank? or c.smiles.blank?
        cids = c.get_cid_from_smiles
        failures << "CAS non-unique" unless cids.size == 1
      end
=end

      #if c.inchi.blank?
        #failures << "InChi missing<br/>" 
      #end
      unless failures.blank?
        @failed << [c.cas,c.name,failures,c.id]
      end
    end
  end

  def conditions_for_collection
    if params[:show] == 'training_set'
      ['training_compound IN (?)', true]
    end
  end

  def display_smiles_with_fragments
    
    # sanitize smiles
    smiles = params[:smiles].chomp.gsub(/\s+/,'')
    display = Rjb::import('DisplayStructure').new

    # TODO: display unknown fragments
    image = display.displaySubstructureP(smiles,session[:activating_fragments],session[:deactivating_fragments],session[:unknown_fragments], session[:activating_p], session[:deactivating_p])
    out=Rjb::import('java.io.ByteArrayOutputStream').new
    Rjb::import('javax.imageio.ImageIO').write(image, "png", out)

    send_data(out.toByteArray, :type => "image/png", :disposition => "inline", :filename => "molecule.png")

	end

	def display_smiles

    # sanitize smiles
    smiles = params[:smiles].chomp.gsub(/\s+/,'')
    display = Rjb::import('DisplayStructure').new
    image = display.displaySmiles(smiles)
    if image
      out=Rjb::import('java.io.ByteArrayOutputStream').new
      Rjb::import('javax.imageio.ImageIO').write(image, "png", out)
      send_data(out.toByteArray, :type => "image/png", :disposition => "inline", :filename => "molecule.png")
    else
      "Cannot display \"#{smiles}\""
    end

	end

end
