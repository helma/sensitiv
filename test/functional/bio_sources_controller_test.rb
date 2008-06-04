require File.dirname(__FILE__) + '/../test_helper'
require 'bio_sources_controller'

# Re-raise errors caught by the controller.
class BioSourcesController; def rescue_action(e) raise e end; end

class BioSourcesControllerTest < Test::Unit::TestCase
  def setup
    @controller = BioSourcesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # Replace this with your real tests.
  def test_truth
    assert true
  end
end
