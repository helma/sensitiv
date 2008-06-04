require File.dirname(__FILE__) + '/../test_helper'
require 'targeted_cell_line_controller'

# Re-raise errors caught by the controller.
class TargetedCellLineController; def rescue_action(e) raise e end; end

class TargetedCellLineControllerTest < Test::Unit::TestCase
  def setup
    @controller = TargetedCellLineController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # Replace this with your real tests.
  def test_truth
    assert true
  end
end
