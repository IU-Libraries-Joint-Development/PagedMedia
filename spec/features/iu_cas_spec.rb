require 'spec_helper'
describe "Access to signin page" do
  it "can sign in user with IU CAS" do
    visit '/users/sign_in'
    page.should have_content("Sign in with IU CAS")
    set_omniauth()
    click_link "Sign in with IU CAS"
    page.should have_content("mock user")  # user name
    page.should have_content("Sign out")
  end

  it "can handle authentication error" do
    OmniAuth.config.mock_auth[:iu_cas] = :invalid_credentials
    visit '/users/sign_in'
    page.should have_content("Sign in with IU CAS")
    click_link "Sign in with IU CAS"
    page.should have_content('Authentication failed.')
  end

end
