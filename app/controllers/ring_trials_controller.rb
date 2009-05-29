class RingTrialsController < ApplicationController

  def index
    @ring_trials = RingTrial.find(:all)
  end

  def controls
    ring_trial = RingTrial.find(params[:id])
    send_file(ring_trial.control_dose_response_curves, :filename => "ring-trial-#{ring_trial.name}_compounds.pdf", :type => "application/pdf", :disposition => 'inline')
  end

  def show
    ring_trial = RingTrial.find(params[:id])
    send_file(ring_trial.dose_response_curves, :filename => "ring-trial-#{ring_trial.name}_compounds.pdf", :type => "application/pdf", :disposition => 'inline')
  end

  def update
    RingTrial.find(params[:id]).create_plots
    redirect_to :action => :index
  end

end
