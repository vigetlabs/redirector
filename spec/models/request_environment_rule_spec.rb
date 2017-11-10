require 'spec_helper'

describe RequestEnvironmentRule do
  subject { create(:request_environment_rule) }

  it { should belong_to(:redirect_rule) }

  it { should validate_presence_of(:redirect_rule) }
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
    rule = build(:request_environment_rule_regex, :environment_value => '[')
    rule.valid?
    expect(rule.errors.messages[:environment_value]).to eq(['is an invalid regular expression'])
  end

  it "should know if it's matched for a non-regex value" do
    expect(subject.matches?({'SERVER_NAME' => 'example.com'})).to be_truthy
    expect(subject.matches?({'HTTP_HOST' => 'www.example.com'})).to be_falsey
    expect(subject.matches?({'SERVER_NAME' => 'example.ca'})).to be_falsey
  end

  context 'with a case sensitive regex value' do
    subject { create(:request_environment_rule_regex) }

    it "should know if it's matched" do
      expect(subject.matches?({'QUERY_STRING' => 'something=value'})).to be_truthy
      expect(subject.matches?({'QUERY_STRING' => 'q=search&something=value'})).to be_truthy
      expect(subject.matches?({'QUERY_STRING' => 'q=search&something=VALUE'})).to be_falsey
      expect(subject.matches?({'QUERY_STRING' => 'q=search&something=bogus'})).to be_falsey
      expect(subject.matches?({'QUERY_STRING' => 'q=search'})).to be_falsey
      expect(subject.matches?({'SERVER_NAME' => 'example.ca'})).to be_falsey
    end
  end

  context 'with a case insensitve regex value' do
    subject { create(:request_environment_rule_regex, :environment_value_is_case_sensitive => false) }

    it "should know if it's matched" do
      expect(subject.matches?({'QUERY_STRING' => 'something=value'})).to be_truthy
      expect(subject.matches?({'QUERY_STRING' => 'q=search&something=value'})).to be_truthy
      expect(subject.matches?({'QUERY_STRING' => 'q=search&something=VALUE'})).to be_truthy
      expect(subject.matches?({'QUERY_STRING' => 'q=search&something=bogus'})).to be_falsey
      expect(subject.matches?({'QUERY_STRING' => 'q=search'})).to be_falsey
      expect(subject.matches?({'SERVER_NAME' => 'example.ca'})).to be_falsey
    end
  end
end
