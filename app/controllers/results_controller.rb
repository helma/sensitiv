class ResultsController < ApplicationController
  active_scaffold :result 
  active_scaffold :result do |conf|

    conf.list.per_page = 50

    columns[:workpackage].label = "WP"
    list.columns = ["workpackage","name","description"] #"document",, "document"
    list.sorting = [{:workpackage_id => :asc}]

    create.link.page = true
    update.link.page = true
    show.link.page = true

  end

  def show
    @result = Result.find(params[:id])
		redirect_to @result.file.sub(/.*public/,'')
  end

  def edit

		if request.post? # create/update

      if params[:id].blank?
        @result = Result.new(params[:result])
        if @result.save
          flash[:notice] = "Creation of #{@result.name} successful"
          redirect_to :action => :list, :id => @result.id
          return
        else
          flash[:notice] = "Creation of #{@result.name} failed"
          # redisplay form
        end
      else
        @result = Result.find(params[:id])
        if @result.update_attributes(params[:result])
          if @result.save
            flash[:notice] = "Update of #{@result.name} successful"
            redirect_to :action => :list, :id => @result.id
            return
          end
        else
          flash[:notice] = "Update of #{@result.name} failed"
          # redisplay form
        end
      end


    else # display form
      if params[:id].blank?
        @result = Result.new
      else
        @result = Result.find(params[:id])
      end
    end

  end
  def new
    redirect_to :action => :edit
  end
end
