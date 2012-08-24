require 'spec_helper'

describe 'Redirector middleware' do
  before do
    FactoryGirl.create(:redirect_rule, :destination => '/news/5', :source => '/my_custom_url')
    FactoryGirl.create(:redirect_rule_regex, :destination => '/news/$1', :source => '/my_custom_url/([A-Za-z0-9_]+)')
    FactoryGirl.create(:redirect_rule_regex, :destination => '/news', :source => 'categoryID=12345')
  end
  
  it 'correctly redirects the visitor for an exact match rule' do
    visit '/my_custom_url'
    current_path.should == '/news/5'
  end

  it 'correctly redirects the visitor for a regex match rule' do
    visit '/my_custom_url/20'
    current_path.should == '/news/20'
  end

  it 'should not do the query string match if the Redirector.include_query_in_source is false' do
    visit '/my_old_url?categoryID=12345'
    current_path.should == '/my_old_url'
  end

  it 'should do the query string match if the Redirector.include_query_in_source is true' do
    original_option = Redirector.include_query_in_source
    Redirector.include_query_in_source = true
    visit '/my_old_url?categoryID=12345'
    current_path.should == '/news'
    Redirector.include_query_in_source = original_option
  end
end
