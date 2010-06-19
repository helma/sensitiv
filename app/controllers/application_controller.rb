# Filters added to this controller will be run for all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base

	before_filter :authorize, :except => [:login, :wp8_upload]
  before_filter :authorize_write, :only => [:new, :new_existing, :create, :edit, :update, :delete], :except => [:wp8_upload]

  layout 'sensitiv'

	ActiveScaffold.set_defaults do |conf|
		conf.actions.exclude :delete
    conf.actions.swap :search, :live_search
	end

  private 

	def authorize
		session[:original_uri] = request.request_uri
		unless User.find_by_id(session[:user_id])
			flash[:notice] = 'Please login with your Sens-it-iv username and password:'
			redirect_to :controller => 'login', :action =>'index'
		end
	end

	def authorize_write
		user = User.find(session[:user_id])
		if user.workpackages.blank? 
			flash[:notice] = 'Please login with your workpackage/group leader password:'
			redirect_to :controller => 'login'
		end
	end

end
