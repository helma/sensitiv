class HelpController < ApplicationController

  def index
  end

	def data_submission
	end

	def general_usage
	end

  def tickets
    redirect_to "http://www.opentox.org/projects/sens-it-iv/tickets/"
  end

end
