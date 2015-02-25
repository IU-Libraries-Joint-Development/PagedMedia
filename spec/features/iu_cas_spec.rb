require 'spec_helper'

describe "Access to signin page" do

  it "can sign in user with IU CAS" do
    visit '/users/sign_in'
    expect(page).to have_content("Sign in with IU CAS")
    set_omniauth()
    click_link "Sign in with IU CAS"
    expect(page).to have_content("1234@indiana.edu")  # user name
    expect(page).to have_content(I18n.t('blacklight.header_links.logout'))
  end

end
