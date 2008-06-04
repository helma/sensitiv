require File.dirname(__FILE__) + '/../test_helper'
require 'cell_lines_controller'

# Re-raise errors caught by the controller.
class CellLinesController; def rescue_action(e) raise e end; end

class CellLinesControllerTest < Test::Unit::TestCase
  def setup
    @controller = CellLinesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # Replace this with your real tests.
  def test_truth
    assert true
  end
end
