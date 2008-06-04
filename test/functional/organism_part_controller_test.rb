require File.dirname(__FILE__) + '/../test_helper'
require 'organism_part_controller'

# Re-raise errors caught by the controller.
class OrganismPartController; def rescue_action(e) raise e end; end

class OrganismPartControllerTest < Test::Unit::TestCase
  def setup
    @controller = OrganismPartController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # Replace this with your real tests.
  def test_truth
    assert true
  end
end
