require 'test_helper'

class RedirectRuleTest < ActiveSupport::TestCase
  context 'RedirectRule' do
    should allow_mass_assignment_of(:source)
    should allow_mass_assignment_of(:source_is_regex)
    should allow_mass_assignment_of(:destination)
    should allow_mass_assignment_of(:active)
    
    should validate_presence_of(:source)
    should validate_presence_of(:destination)
    should validate_presence_of(:active)

    should allow_value('0').for(:source_is_regex)
    should allow_value('1').for(:source_is_regex)
    should allow_value(true).for(:source_is_regex)
    should allow_value(false).for(:source_is_regex)

    should 'not allow an invalid regex' do
      rule = RedirectRule.new(:source => '[', :source_is_regex => true,
        :destination => 'http://www.example.com', :active => true)
      assert rule.invalid?
      assert rule.errors.include?(:source)
    end

    context '.match_for' do
      setup do
        @rule = FactoryGirl.create(:redirect_rule)
      end
      
      should 'return nil if there is no matching rule' do
        assert_nil RedirectRule.match_for('/someplace')
      end

      should 'return the rule if there is a matching rule' do
        assert_equal @rule, RedirectRule.match_for('/catchy_thingy')
      end
    end

    context '.destination_for' do
      setup do
        @rule1 = FactoryGirl.create(:redirect_rule)
        @rule2 = FactoryGirl.create(:redirect_rule, :source => '[A-Za-z1-9_]+shiny\/[A-Za-z1-9_]+',
          :source_is_regex => true, :destination => 'http://www.example.com/news/20')
      end

      should 'find a regex match' do
        assert_equal 'http://www.example.com/news/20',
          RedirectRule.destination_for('/new_shiny/from_company')
      end

      should 'find a string match' do
        assert_equal 'http://www.example.com/products/1',
          RedirectRule.destination_for('/catchy_thingy')
      end

      should 'return nil if there is no matching rule' do
        assert_nil RedirectRule.destination_for('/someplace')
      end
    end
  end
end
