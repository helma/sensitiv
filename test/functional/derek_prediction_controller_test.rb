require File.dirname(__FILE__) + '/../test_helper'
require 'derek_prediction_controller'

# Re-raise errors caught by the controller.
class DerekPredictionController; def rescue_action(e) raise e end; end

class DerekPredictionControllerTest < Test::Unit::TestCase
  def setup
    @controller = DerekPredictionController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # Replace this with your real tests.
  def test_truth
    assert true
  end
end
