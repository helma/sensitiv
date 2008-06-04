require File.dirname(__FILE__) + '/../test_helper'
require 'organism_controller'

# Re-raise errors caught by the controller.
class OrganismController; def rescue_action(e) raise e end; end

class OrganismControllerTest < Test::Unit::TestCase
  def setup
    @controller = OrganismController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # Replace this with your real tests.
  def test_truth
    assert true
  end
end
