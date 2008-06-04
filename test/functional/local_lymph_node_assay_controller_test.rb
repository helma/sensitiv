require File.dirname(__FILE__) + '/../test_helper'
require 'local_lymph_node_assay_controller'

# Re-raise errors caught by the controller.
class LocalLymphNodeAssayController; def rescue_action(e) raise e end; end

class LocalLymphNodeAssayControllerTest < Test::Unit::TestCase
  def setup
    @controller = LocalLymphNodeAssayController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # Replace this with your real tests.
  def test_truth
    assert true
  end
end
