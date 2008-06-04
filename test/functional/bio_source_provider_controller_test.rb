require File.dirname(__FILE__) + '/../test_helper'
require 'bio_source_provider_controller'

# Re-raise errors caught by the controller.
class BioSourceProviderController; def rescue_action(e) raise e end; end

class BioSourceProviderControllerTest < Test::Unit::TestCase
  def setup
    @controller = BioSourceProviderController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # Replace this with your real tests.
  def test_truth
    assert true
  end
end
