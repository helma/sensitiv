require File.dirname(__FILE__) + '/../test_helper'
require 'developmental_stage_controller'

# Re-raise errors caught by the controller.
class DevelopmentalStageController; def rescue_action(e) raise e end; end

class DevelopmentalStageControllerTest < Test::Unit::TestCase
  def setup
    @controller = DevelopmentalStageController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # Replace this with your real tests.
  def test_truth
    assert true
  end
end
