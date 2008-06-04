require File.dirname(__FILE__) + '/../test_helper'
require 'training_compounds_controller'

# Re-raise errors caught by the controller.
class TrainingCompoundsController; def rescue_action(e) raise e end; end

class TrainingCompoundsControllerTest < Test::Unit::TestCase
  def setup
    @controller = TrainingCompoundsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # Replace this with your real tests.
  def test_truth
    assert true
  end
end
