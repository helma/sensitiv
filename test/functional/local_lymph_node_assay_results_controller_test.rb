require File.dirname(__FILE__) + '/../test_helper'
require 'local_lymph_node_assay_results_controller'

# Re-raise errors caught by the controller.
class LocalLymphNodeAssayResultsController; def rescue_action(e) raise e end; end

class LocalLymphNodeAssayResultsControllerTest < Test::Unit::TestCase
  def setup
    @controller = LocalLymphNodeAssayResultsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # Replace this with your real tests.
  def test_truth
    assert true
  end
end
