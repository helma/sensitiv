require File.dirname(__FILE__) + '/../test_helper'
require 'skin_sensitisation_controller'

# Re-raise errors caught by the controller.
class SkinSensitisationController; def rescue_action(e) raise e end; end

class SkinSensitisationControllerTest < Test::Unit::TestCase
  def setup
    @controller = SkinSensitisationController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # Replace this with your real tests.
  def test_truth
    assert true
  end
end
