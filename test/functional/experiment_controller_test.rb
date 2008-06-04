require File.dirname(__FILE__) + '/../test_helper'
require 'experiment_controller'

# Re-raise errors caught by the controller.
class ExperimentController; def rescue_action(e) raise e end; end

class ExperimentControllerTest < Test::Unit::TestCase
  def setup
    @controller = ExperimentController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # Replace this with your real tests.
  def test_truth
    assert true
  end
end
