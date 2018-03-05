require 'spec_helper'

describe 'Redirector middleware', :type => :feature do
  before do
    create(:redirect_rule, :destination => '/news/5', :source => '/my_custom_url')
    create(:redirect_rule_regex, :destination => '/news/$1', :source => '/my_custom_url/([A-Za-z0-9_]+)')
    create(:redirect_rule_regex, :destination => '/news', :source => 'categoryID=12345')
  end

  it 'correctly redirects the visitor for an exact match rule' do
    visit '/my_custom_url'
    expect(current_path).to eq('/news/5')
  end

  it 'correctly redirects the visitor for a regex match rule' do
    visit '/my_custom_url/20'
    expect(current_path).to eq('/news/20')
  end

  it 'should not do the query string match if the Redirector.include_query_in_source is false' do
    visit '/my_old_url?categoryID=12345'
    expect(current_path).to eq('/my_old_url')
  end

  it 'should do the query string match if the Redirector.include_query_in_source is true' do
    original_option = Redirector.include_query_in_source
    Redirector.include_query_in_source = true
    visit '/my_old_url?categoryID=12345'
    expect(current_path).to eq('/news')
    Redirector.include_query_in_source = original_option
  end

  it 'should preserve the query string if the Redirector.preserve_query is true' do
    original_option = Redirector.preserve_query
    Redirector.preserve_query = true
    visit '/my_custom_url/20?categoryID=43257'
    uri = URI.parse(current_url)
    expect(uri.query).to eq('categoryID=43257')
    expect(current_path).to eq('/news/20')
    Redirector.preserve_query = original_option
  end

  it 'should stil work with silenced ActiveRecord logs' do
    original_option = Redirector.silence_sql_logs
    Redirector.silence_sql_logs = true
    visit '/my_custom_url/20'
    expect(current_path).to eq('/news/20')
    Redirector.preserve_query = original_option
  end

  it 'handles requests with or without a port specified' do
    Capybara.app_host = 'http://example.com'

    visit '/my_custom_url'
    expect(current_url).to eq('http://example.com/news/5')

    Capybara.app_host = 'http://example.com:3000'

    visit '/my_custom_url'
    expect(current_url).to eq('http://example.com:3000/news/5')
  end

  it 'foregoes search if ignored path pattern is detected' do
    original_option = Redirector.ignored_patterns
    Redirector.ignored_patterns = [/^\/my_custom_url\/.+/]

    visit '/my_custom_url/20'
    expect(current_path).to eq('/my_custom_url/20')

    Redirector.ignored_patterns = original_option
  end

  unless Rails.version =~ /\A4\.2\.\d\z/
    it 'handles invalid URIs properly' do
      bad_rule = create(:redirect_rule_regex,
        :destination => 'http://www.example.com/invalid)e2',
        :source => '^/custom(.*)$',
      )

      begin
        visit '/custome2'
      rescue Redirector::RuleError => e
        expect(e.message).to eq("RedirectRule #{bad_rule.id} generated the bad destination: http://www.example.com)e2")
      end
    end
  end
end
