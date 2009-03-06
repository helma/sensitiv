require "#{File.dirname(__FILE__)}/../test_helper"

class LoginTest < ActionController::IntegrationTest  

  def test_login
    visit "/login/login"
    fill_in "name", :with => "participantSII"
    fill_in "password", :with => "284872"
    click_button 
    assert_contain "Welcome to Sens-it-iv!"
  end

end
