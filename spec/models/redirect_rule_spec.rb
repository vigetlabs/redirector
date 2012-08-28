require 'spec_helper'

describe RedirectRule do
  subject { FactoryGirl.create(:redirect_rule) }
  let!(:rule) { subject }

  it { should have_many(:request_environment_rules) }

  it { should allow_mass_assignment_of(:source) }
  it { should allow_mass_assignment_of(:source_is_regex) }
  it { should allow_mass_assignment_of(:destination) }
  it { should allow_mass_assignment_of(:active) }
  it { should allow_mass_assignment_of(:source_is_case_sensitive) }
  it { should allow_mass_assignment_of(:request_environment_rules_attributes) }

  it { should accept_nested_attributes_for(:request_environment_rules) }

  it { should validate_presence_of(:source) }
  it { should validate_presence_of(:destination) }

  it { should allow_value('0').for(:active) }
  it { should allow_value('1').for(:active) }
  it { should allow_value(true).for(:active) }
  it { should allow_value(false).for(:active) }

  it { should allow_value('0').for(:source_is_regex) }
  it { should allow_value('1').for(:source_is_regex) }
  it { should allow_value(true).for(:source_is_regex) }
  it { should allow_value(false).for(:source_is_regex) }

  it { should allow_value('0').for(:source_is_case_sensitive) }
  it { should allow_value('1').for(:source_is_case_sensitive) }
  it { should allow_value(true).for(:source_is_case_sensitive) }
  it { should allow_value(false).for(:source_is_case_sensitive) }

  it 'should not allow an invalid regex' do
    new_rule = RedirectRule.new(:source => '[', :source_is_regex => true,
      :destination => 'http://www.example.com', :active => true)
    new_rule.errors_on(:source).should == ['is an invalid regular expression']
  end

  describe '.match_for' do
    it 'returns nil if there is no matching rule' do
      RedirectRule.match_for('/someplace', {}).should be_nil
    end

    it 'returns the rule if there is a matching rule' do
      RedirectRule.match_for('/catchy_thingy', {}).should == subject
    end

    context 'for a case sensitive regex match' do
      let!(:regex_rule){ FactoryGirl.create(:redirect_rule_regex, :source_is_case_sensitive => true) }
      
      it 'returns the rule if it matches the case' do
        RedirectRule.match_for('/new_shiny/from_company', {}).should == regex_rule
      end

      it 'returns nil if it does not match the case' do
        RedirectRule.match_for('/new_SHINY/from_company', {}).should be_nil
      end
    end

    context 'for a case insensitive regex match' do
      let!(:regex_rule){ FactoryGirl.create(:redirect_rule_regex) }
      
      it 'returns the rule if it matches the case' do
        RedirectRule.match_for('/new_shiny/from_company', {}).should == regex_rule
      end

      it 'returns the rule if it does not match the case' do
        RedirectRule.match_for('/new_SHINY/from_company', {}).should == regex_rule
      end
    end

    context 'with a rule with one environment condition' do
      before do
        FactoryGirl.create(:request_environment_rule, :redirect_rule => subject)
      end
    
      it 'should find the rule if it matches' do
        RedirectRule.match_for('/catchy_thingy', {'SERVER_NAME' => 'example.com'}).should == subject
      end
    
      it 'should not find the rule if there is no match' do
        RedirectRule.match_for('/catchy_thingy', {'SERVER_NAME' => 'example.ca'}).should be_nil
      end
    end
    
    context 'with a rule with multiple environment conditions' do
      before do
        FactoryGirl.create(:request_environment_rule, :redirect_rule => subject)
        FactoryGirl.create(:request_environment_rule_regex, :redirect_rule => subject)
      end

      it 'should find the rule if it matches' do
        RedirectRule.match_for('/catchy_thingy', {'SERVER_NAME' => 'example.com',
          'QUERY_STRING' => 's=bogus&something=value'}).should == subject
      end
    
      it 'should not find the rule if there is no match' do
        RedirectRule.match_for('/catchy_thingy', {'SERVER_NAME' => 'example.com', 
          "QUERY_STRING" => 's=bogus&something=wrong'}).should be_nil
      end
    end
    
    context 'with multiple rules with multiple environment conditions' do
      let!(:rule2){ FactoryGirl.create(:redirect_rule) }
      before do
        FactoryGirl.create(:request_environment_rule, :redirect_rule => subject)
        FactoryGirl.create(:request_environment_rule_regex, :redirect_rule => subject)
        FactoryGirl.create(:request_environment_rule, :redirect_rule => rule2)
        FactoryGirl.create(:request_environment_rule_regex, :redirect_rule => rule2,
          :environment_value => 'another=value')
      end

      it 'should find the rule if it matches' do
        RedirectRule.match_for('/catchy_thingy', {'SERVER_NAME' => 'example.com',
          'QUERY_STRING' => 's=bogus&something=value'}).should == subject
      end

      it 'should find the other rule if it matches' do
        RedirectRule.match_for('/catchy_thingy', {'SERVER_NAME' => 'example.com',
          'QUERY_STRING' => 's=bogus&another=value'}).should == rule2
      end

      it 'should not find the rule if there is no match' do
        RedirectRule.match_for('/catchy_thingy', {'SERVER_NAME' => 'example.com', 
          "QUERY_STRING" => 's=bogus&something=wrong'}).should be_nil
      end
    end
  
    context 'with a regex rule that also matches an exact string match' do
      let!(:regex_rule){ FactoryGirl.create(:redirect_rule_regex, :source => '[A-Za-z0-9]_thingy') }
      
      it 'should return the exact match' do
        RedirectRule.match_for('/catchy_thingy', {}).should == subject
      end
    end
  end

  describe '.destination_for' do
    let!(:regex_rule) { FactoryGirl.create(:redirect_rule_regex) }

    it 'should find a regex match' do
      RedirectRule.destination_for('/new_shiny/from_company', {}).should == 'http://www.example.com/news/from_company'
    end

    it 'should find a string match' do
      RedirectRule.destination_for('/catchy_thingy', {}).should == 'http://www.example.com/products/1'
    end

    it 'should return nil if there is no matching rule' do
      RedirectRule.destination_for('/someplace', {}).should be_nil
    end
  end

  describe '#evaluated_destination_for' do
    let(:regex_rule) { FactoryGirl.create(:redirect_rule_regex) }
    
    it 'returns the destination for a non regex rule' do
      subject.evaluated_destination_for('/catchy_thingy').should == 'http://www.example.com/products/1'
    end

    it 'returns the evaluated destination for a regex rule' do
      regex_rule.evaluated_destination_for('/new_shiny/from_company').should == 'http://www.example.com/news/from_company'
    end
  end
end