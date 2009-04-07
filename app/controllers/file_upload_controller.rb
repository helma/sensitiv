require 'roo'

class FileUploadController <  ActionController::Base

  layout 'sensitiv'

  def index
  end

  def new

    case params[:workpackage]
    when '8'
      redirect_to :controller => :wp8_upload, :action => :index
    when '1'
      redirect_to :controller => :wp1_upload, :action => :index
    else
      redirect_to :controller => :file_upload, :action => :index
    end
    
  end

end
