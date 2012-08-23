require 'spec_helper'

describe RedirectRule do
  subject { FactoryGirl.create(:redirect_rule) }
  let!(:rule) { subject }

  it { should allow_mass_assignment_of(:source) }
  it { should allow_mass_assignment_of(:source_is_regex) }
  it { should allow_mass_assignment_of(:destination) }
  it { should allow_mass_assignment_of(:active) }
  
  it { should validate_presence_of(:source) }
  it { should validate_presence_of(:destination) }
  it { should validate_presence_of(:active) }

  it { should allow_value('0').for(:source_is_regex) }
  it { should allow_value('1').for(:source_is_regex) }
  it { should allow_value(true).for(:source_is_regex) }
  it { should allow_value(false).for(:source_is_regex) }

  it 'should not allow an invalid regex' do
    rule = RedirectRule.new(:source => '[', :source_is_regex => true,
      :destination => 'http://www.example.com', :active => true)
    rule.should have(1).errors_on(:source)
  end

  describe '.match_for' do
    it 'returns nil if there is no matching rule' do
      RedirectRule.match_for('/someplace').should be_nil
    end

    it 'returns the rule if there is a matching rule' do
      RedirectRule.match_for('/catchy_thingy').should == subject
    end
  end

  describe '.destination_for' do
    let!(:rule2) { FactoryGirl.create(:redirect_rule, :source => '[A-Za-z1-9_]+shiny\/[A-Za-z1-9_]+',
      :source_is_regex => true, :destination => 'http://www.example.com/news/20') }

    it 'should find a regex match' do
      RedirectRule.destination_for('/new_shiny/from_company').should == 'http://www.example.com/news/20'
    end

    it 'should find a string match' do
      RedirectRule.destination_for('/catchy_thingy').should == 'http://www.example.com/products/1'
    end

    it 'should return nil if there is no matching rule' do
      RedirectRule.destination_for('/someplace').should be_nil
    end
  end
end