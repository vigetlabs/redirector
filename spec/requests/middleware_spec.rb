require 'spec_helper'

describe 'Redirector middleware' do
  before do
    FactoryGirl.create(:redirect_rule, :destination => '/news/5', :source => '/my_custom_url')
  end
  
  it 'correctly redirects the visitor' do
    visit '/my_custom_url'
    current_path.should == '/news/5'
  end
end
