require 'spec_helper'

describe "Navigation" do
  include Capybara::DSL
  
  it "should be a valid app" do
    ::Rails.application.should be_a(App::Application)
  end
end
