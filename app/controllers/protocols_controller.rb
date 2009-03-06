class ProtocolsController < ApplicationController

  active_scaffold :protocol do |conf|

    conf.list.per_page = 50

    columns[:workpackage].label = "WP"
    columns[:audited].label = "Approved by WP leader"
    list.columns = ["workpackage","name","description", "audited"] #"document",, "document"
    list.sorting = [{:workpackage_id => :asc}]

    create.link.page = true
    update.link.page = true
    show.link.page = true

  end

  def show
    @protocol = Protocol.find(params[:id])
    if @protocol.file
      redirect_to @protocol.file.sub(/.*public/,'')
    end
  end

  def edit

		if request.post? # create/update

      if params[:id].blank?
        @protocol = Protocol.new(params[:protocol])
        audit_check
        add_experiment
        if @protocol.save
          flash[:notice] = "Update of #{@protocol.name} successful"
          redirect_to :action => :list, :id => @protocol.id
          return
        else
          flash[:notice] = "Update of #{@protocol.name} failed"
          # redisplay form
        end
      else
        @protocol = Protocol.find(params[:id])
        if @protocol.update_attributes(params[:protocol])
          audit_check
          add_experiment
          if @protocol.save
            flash[:notice] = "Update of #{@protocol.name} successful"
            redirect_to :action => :list, :id => @protocol.id
            return
          end
        else
          flash[:notice] = "Update of #{@protocol.name} failed"
          # redisplay form
        end
      end


    else # display form
      if params[:id].blank?
        @protocol = Protocol.new
      else
        @protocol = Protocol.find(params[:id])
      end
    end

  end

  def new
    redirect_to :action => :edit
  end

  def audit
		user = User.find(session[:user_id])
    protocol = Protocol.find(params[:id])
    correct_user = false

    if user.name =~ /wp.*_leader/
      user.workpackages.each do |w|
        correct_user = true if protocol.workpackage == w
      end
    end

    if correct_user
      protocol.audited = true 
      protocol.save
      redirect_to :action => :list, :id => protocol.id
    else
			flash[:notice] = "Please login with your workpackage leader password for WP#{protocol.workpackage.nr}:"
			redirect_to :controller => 'login', :workpackage_id => protocol.workpackage.id
		end

  end

  private

  def audit_check
    user = User.find(session[:user_id])
    if user.name =~ /wp.*_leader/
      user.workpackages.each do |w|
        @protocol.audited = true if @protocol.workpackage == w
      end
    end
  end

  def add_experiment
    @protocol.experiments << Experiment.find(session[:exp_id]) unless session[:exp_id].blank?
  end

  def clear_experiment_id
    session[:exp_id] = nil
  end
end
