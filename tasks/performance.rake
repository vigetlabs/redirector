namespace :performance do
  desc "Test the performance of redirector (2005 records; 5 matches too evaluate the env against)"
  task :benchmark do
    require File.expand_path("../../spec/dummy/config/environment.rb",  __FILE__)

    ActiveRecord::Base.transaction do
      base_regex = "something/with_[A-Za-z0-9_]+/"
      base_regex_attributes = {
        :active                   => true,
        :source_is_regex          => true,
        :source_is_case_sensitive => true,
        :destination              => 'http://www.example.com/products/1'
      }
      RedirectRule.create!(base_regex_attributes.merge(:source => "#{base_regex}?"))
      1000.times do |i|
        number_of_extras = i.modulo(5) + 1
        regex = "#{base_regex}#{"(bogus|bonus|123456|some_other_path)/"*number_of_extras}#{i}"
        RedirectRule.create!(base_regex_attributes.merge(:source => regex))
      end

      base_path = "/some/basic/path/to/"
      base_string_attributes = {
        :active                   => true,
        :source_is_regex          => false,
        :destination              => 'http://www.example.com/products/1'
      }
      1000.times do |i|
        RedirectRule.create!(base_regex_attributes.merge(:source => "#{base_path}#{i}"))
      end

      base_real_regex_matches = "my_real_match/to/something/"
      # First match
      rule1 = RedirectRule.create!(base_regex_attributes.merge(:source => "#{base_real_regex_matches}(some|value)", :destination => '/my_real_url'))
      rule1.request_environment_rules.create!(:environment_key_name => 'SERVER_NAME',
        :environment_value => 'my_domain.com',
        :environment_value_is_regex => false)
      rule1.request_environment_rules.create!(:environment_key_name => 'QUERY_STRING',
        :environment_value => 'other_param=(real|news_id)',
        :environment_value_is_regex => true)
      # Second match
      rule2 = RedirectRule.create!(base_regex_attributes.merge(:source => "#{base_real_regex_matches}[A-Za-z0-9_]+/?"))
      rule2.request_environment_rules.create!(:environment_key_name => 'SERVER_NAME',
        :environment_value => 'example.com',
        :environment_value_is_regex => false)
      rule2.request_environment_rules.create!(:environment_key_name => 'QUERY_STRING',
        :environment_value => 'example=(test|product_id)',
        :environment_value_is_regex => true)
      # Third match
      rule3 = RedirectRule.create!(base_regex_attributes.merge(:source => "#{base_real_regex_matches}[A-Za-z_]+/[A-Za-z0-9_]+"))
      rule3.request_environment_rules.create!(:environment_key_name => 'SERVER_NAME',
        :environment_value => 'example.com',
        :environment_value_is_regex => false)
      rule3.request_environment_rules.create!(:environment_key_name => 'QUERY_STRING',
        :environment_value => 'example=(test|product_id)',
        :environment_value_is_regex => true)
      # Fourth match
      rule4 = RedirectRule.create!(base_regex_attributes.merge(:source => "#{base_real_regex_matches}[A-Za-z_]+/[A-Za-z]+"))
      rule4.request_environment_rules.create!(:environment_key_name => 'SERVER_NAME',
        :environment_value => 'example.com',
        :environment_value_is_regex => false)
      rule4.request_environment_rules.create!(:environment_key_name => 'QUERY_STRING',
        :environment_value => 'example=(test|product_id)',
        :environment_value_is_regex => true)
      rule5 = RedirectRule.create!(base_regex_attributes.merge(:source => "#{base_real_regex_matches}(some|value)/other_value"))
      rule5.request_environment_rules.create!(:environment_key_name => 'SERVER_NAME',
        :environment_value => 'example.com',
        :environment_value_is_regex => false)
      rule5.request_environment_rules.create!(:environment_key_name => 'QUERY_STRING',
        :environment_value => 'example=(test|product_id)',
        :environment_value_is_regex => true)
      
      
      require 'benchmark'
      puts Benchmark.measure {
        100.times do
          RedirectRule.destination_for('/start/my_real_match/to/something/value/other_value', {
            "SERVER_NAME" => 'my_domain.com',
            "QUERY_STRING" => 'other_param=news_id'
          })
        end
      }
      
      raise ActiveRecord::Rollback
    end
  end
end
