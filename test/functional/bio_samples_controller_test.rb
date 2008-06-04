require File.dirname(__FILE__) + '/../test_helper'
require 'bio_samples_controller'

# Re-raise errors caught by the controller.
class BioSamplesController; def rescue_action(e) raise e end; end

class BioSamplesControllerTest < Test::Unit::TestCase
  def setup
    @controller = BioSamplesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # Replace this with your real tests.
  def test_truth
    assert true
  end
end
