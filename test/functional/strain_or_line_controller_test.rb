require File.dirname(__FILE__) + '/../test_helper'
require 'strain_or_line_controller'

# Re-raise errors caught by the controller.
class StrainOrLineController; def rescue_action(e) raise e end; end

class StrainOrLineControllerTest < Test::Unit::TestCase
  def setup
    @controller = StrainOrLineController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # Replace this with your real tests.
  def test_truth
    assert true
  end
end
