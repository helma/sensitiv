class LoginController < ApplicationController

  skip_before_filter :authorize

	def index
		if request.post?

      if params[:workpackage_id]
        user = User.authenticate_with_wp(params[:name], params[:password], params[:workpackage_id])
      else
        user = User.authenticate(params[:name], params[:password])
      end

			if user 
				session[:user_id] = user.id
				uri = session[:original_uri] unless session[:original_uri] =~ /login/
				session[:original_uri] = nil
				redirect_to(uri || { :controller => 'home', :action => 'index'})
			else
				flash[:notice] = "Invalid username (#{params[:name]}) or password (#{params[:password]}) #{params[:workpackage_id]}"
			end
		end
	end
end
