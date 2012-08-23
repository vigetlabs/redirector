require 'spec_helper'

describe 'Redirector middleware' do
  before do
    FactoryGirl.create(:redirect_rule, :destination => '/news/5', :source => '/my_custom_url')
    FactoryGirl.create(:redirect_rule_regex, :destination => '/news/$1', :source => '/my_custom_url/([A-Za-z0-9_]+)')
  end
  
  it 'correctly redirects the visitor for an exact match rule' do
    visit '/my_custom_url'
    current_path.should == '/news/5'
  end

  it 'correctly redirects the visitor for a regex match rule' do
    visit '/my_custom_url/20'
    current_path.should == '/news/20'
  end
end
