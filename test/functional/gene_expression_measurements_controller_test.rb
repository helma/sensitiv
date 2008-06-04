require File.dirname(__FILE__) + '/../test_helper'
require 'gene_expression_measurements_controller'

# Re-raise errors caught by the controller.
class GeneExpressionMeasurementsController; def rescue_action(e) raise e end; end

class GeneExpressionMeasurementsControllerTest < Test::Unit::TestCase
  def setup
    @controller = GeneExpressionMeasurementsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # Replace this with your real tests.
  def test_truth
    assert true
  end
end
