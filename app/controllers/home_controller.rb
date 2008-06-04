class HomeController < ApplicationController

  def index
	end

	def website
		redirect_to "https://sens-it-iv-internal.org/wwwdata/"
		#render_text Net::HTTP.get_response("sens-it-iv-internal.org",'/wwwdata/').body
	end

	def forum
		redirect_to "https://sens-it-iv-internal.org/phpbb/", :layout => true
	end

end
