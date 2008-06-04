# Filters added to this controller will be run for all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base

	before_filter :authorize, :except => [:login]

  # authorize write has to be defined in each controller
  before_filter :authorize_write, :only => [:new, :new_existing, :create, :edit, :update, :delete]

  layout 'sensitiv'
  include ExceptionNotifiable

	ActiveScaffold.set_defaults do |conf|
		conf.actions.exclude :delete
    conf.actions.swap :search, :live_search
	end

  private 

	def authorize
		session[:original_uri] = request.request_uri
		unless User.find_by_id(session[:user_id])
			flash[:notice] = 'Please login with your Sens-it-iv username and password:'
			redirect_to :controller => 'login', :action =>'login'
		end
	end

  def authorize_write
    render :text => User.find(session[:user_id]).name +	": You are not authorised to perform this action!"
  end
end
