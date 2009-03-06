require "#{File.dirname(__FILE__)}/../test_helper"

class ProtocolsTest < ActionController::IntegrationTest  

  #fixtures :users

  def test_protocols
    login
    click_link "Protocols"
    assert_contain "Description"
    assert_contain "Approved by WP leader"
    assert_contain "Chemicals of the tutorial list: general properties"
  end

  def login
    visit "/login"
    fill_in "name", :with => "participantSII"
    fill_in "password", :with => "284872"
    click_button 
    assert_contain "Welcome to Sens-it-iv!"
  end

end
