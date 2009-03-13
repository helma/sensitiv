class ExperimentsController < ApplicationController

  before_filter :set_experiment_id, :only => :nested

	active_scaffold :experiment do |config|

    config.actions.exclude :show
    config.actions.exclude :create
    config.actions.exclude :update

    columns[:workpackage].label = "WP"
		columns[:people].label = 'Submitter'
    columns[:audited].label = "Approved by WP leader"
		config.columns[:workpackage].form_ui = :select
		config.columns[:protocols].form_ui = :select
		config.columns[:title].form_ui = :textarea
    config.columns[:title].options = { :cols => 95}
		config.columns[:description].form_ui = :textarea
    config.columns[:description].options = {:cols => 95 }
    config.columns[:protocols].search_sql = "protocols.name"

		list.columns = [:workpackage, :title, :description, :date, :protocols, :people, :audited]
    list.sorting = [{:workpackage_id => :asc}]

		config.nested.add_link("Show", [:treatments])

=begin
    # create
    config.create.link.page = true
		create.columns = [:workpackage, :title, :description, :date]

    # update
    config.update.link.page = true
		update.columns = [:workpackage, :title, :description, :date]
=end

	end

  def audit
		user = User.find(session[:user_id])
    experiment = Experiment.find(params[:id])
    correct_user = false

    if user.name =~ /wp.*_leader/
      user.workpackages.each do |w|
        correct_user = true if experiment.workpackage == w
      end
    end

    if correct_user
      experiment.audited = true 
      experiment.save
      redirect_to :action => :list, :id => experiment.id
    else
			flash[:notice] = "Please login with your workpackage leader password for WP#{experiment.workpackage.nr}:"
			redirect_to :controller => 'login', :action =>'index', :workpackage_id => experiment.workpackage.id
		end

  end

  private 

  def set_experiment_id
    session[:exp_id] = params[:id]
  end

end
