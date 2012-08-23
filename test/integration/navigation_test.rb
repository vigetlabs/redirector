require 'test_helper'

class NavigationTest < ActionDispatch::IntegrationTest
  context 'With redirect rules' do
    setup do
      FactoryGirl.create(:redirect_rule, :destination => '/news/5', :source => '/my_custom_url')
    end
    
    should 'correctly redirect' do
      visit '/my_custom_url'
      assert_equal '/news/5', current_path
    end
  end
end
