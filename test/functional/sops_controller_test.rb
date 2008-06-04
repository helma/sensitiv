require File.dirname(__FILE__) + '/../test_helper'
require 'sops_controller'

# Re-raise errors caught by the controller.
class SopsController; def rescue_action(e) raise e end; end

class SopsControllerTest < Test::Unit::TestCase
  def setup
    @controller = SopsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # Replace this with your real tests.
  def test_truth
    assert true
  end
end
