require File.dirname(__FILE__) + '/../test_helper'
require 'vehicles_controller'

# Re-raise errors caught by the controller.
class VehiclesController; def rescue_action(e) raise e end; end

class VehiclesControllerTest < Test::Unit::TestCase
  def setup
    @controller = VehiclesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # Replace this with your real tests.
  def test_truth
    assert true
  end
end
