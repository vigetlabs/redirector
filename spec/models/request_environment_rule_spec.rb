require 'spec_helper'

describe RequestEnvironmentRule do
  subject { FactoryGirl.create(:request_environment_rule) }

  it { should belong_to(:redirect_rule) }

  it { should allow_mass_assignment_of(:redirect_rule_id) }
  it { should allow_mass_assignment_of(:environment_key_name) }
  it { should allow_mass_assignment_of(:environment_value) }
  it { should allow_mass_assignment_of(:environment_value_is_regex) }
  it { should allow_mass_assignment_of(:environment_value_is_case_sensitive) }
  
  it { should validate_presence_of(:redirect_rule_id) }
  it { should validate_presence_of(:environment_key_name) }
  it { should validate_presence_of(:environment_value) }

  it { should allow_value('0').for(:environment_value_is_regex) }
  it { should allow_value('1').for(:environment_value_is_regex) }
  it { should allow_value(true).for(:environment_value_is_regex) }
  it { should allow_value(false).for(:environment_value_is_regex) }

  it { should allow_value('0').for(:environment_value_is_case_sensitive) }
  it { should allow_value('1').for(:environment_value_is_case_sensitive) }
  it { should allow_value(true).for(:environment_value_is_case_sensitive) }
  it { should allow_value(false).for(:environment_value_is_case_sensitive) }

  it 'should not allow an invalid regex' do
    rule = FactoryGirl.build(:request_environment_rule_regex, :environment_value => '[')
    rule.errors_on(:environment_value).should == ['is an invalid regular expression']
  end

  it "should know if it's matched for a non-regex value" do
    subject.matches?({'SERVER_NAME' => 'example.com'}).should be_true
    subject.matches?({'HTTP_HOST' => 'www.example.com'}).should be_false
    subject.matches?({'SERVER_NAME' => 'example.ca'}).should be_false
  end

  context 'with a case sensitive regex value' do
    subject { FactoryGirl.create(:request_environment_rule_regex) }
    
    it "should know if it's matched" do
      subject.matches?({'QUERY_STRING' => 'something=value'}).should be_true
      subject.matches?({'QUERY_STRING' => 'q=search&something=value'}).should be_true
      subject.matches?({'QUERY_STRING' => 'q=search&something=VALUE'}).should be_false
      subject.matches?({'QUERY_STRING' => 'q=search&something=bogus'}).should be_false
      subject.matches?({'QUERY_STRING' => 'q=search'}).should be_false
      subject.matches?({'SERVER_NAME' => 'example.ca'}).should be_false
    end
  end

  context 'with a case insensitve regex value' do
    subject { FactoryGirl.create(:request_environment_rule_regex, :environment_value_is_case_sensitive => false) }
    
    it "should know if it's matched" do
      subject.matches?({'QUERY_STRING' => 'something=value'}).should be_true
      subject.matches?({'QUERY_STRING' => 'q=search&something=value'}).should be_true
      subject.matches?({'QUERY_STRING' => 'q=search&something=VALUE'}).should be_true
      subject.matches?({'QUERY_STRING' => 'q=search&something=bogus'}).should be_false
      subject.matches?({'QUERY_STRING' => 'q=search'}).should be_false
      subject.matches?({'SERVER_NAME' => 'example.ca'}).should be_false
    end
  end
end