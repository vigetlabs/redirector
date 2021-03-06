require 'spec_helper'

describe RedirectRule do
  subject { create(:redirect_rule) }
  let!(:rule) { subject }

  it { is_expected.to have_many(:request_environment_rules) }

  it { is_expected.to accept_nested_attributes_for(:request_environment_rules) }

  it { is_expected.to validate_presence_of(:source) }
  it { is_expected.to validate_presence_of(:destination) }

  it { is_expected.to allow_value('0').for(:active) }
  it { is_expected.to allow_value('1').for(:active) }
  it { is_expected.to allow_value(true).for(:active) }
  it { is_expected.to allow_value(false).for(:active) }

  it { is_expected.to allow_value('0').for(:source_is_regex) }
  it { is_expected.to allow_value('1').for(:source_is_regex) }
  it { is_expected.to allow_value(true).for(:source_is_regex) }
  it { is_expected.to allow_value(false).for(:source_is_regex) }

  it { is_expected.to allow_value('0').for(:source_is_case_sensitive) }
  it { is_expected.to allow_value('1').for(:source_is_case_sensitive) }
  it { is_expected.to allow_value(true).for(:source_is_case_sensitive) }
  it { is_expected.to allow_value(false).for(:source_is_case_sensitive) }

  it 'should not allow an invalid regex' do
    new_rule = RedirectRule.new(
      :source => '[',
      :source_is_regex => true,
      :destination => 'http://www.example.com',
      :active => true
    )
    new_rule.validate
    expect(new_rule.errors[:source]).to eq(['is an invalid regular expression'])
  end

  describe 'strip_source_whitespace before_save callback' do
    it 'strips leading and trailing whitespace when saved' do
      subject = build(:redirect_rule, :source => ' /needs-stripping ')

      subject.save
      expect(subject.reload.source).to eq('/needs-stripping')
    end
  end

  describe 'strip_destination_whitespace before_save callback' do
    it 'strips leading and trailing whitespace when saved' do
      subject = build(:redirect_rule, :destination => ' /needs-stripping ')

      subject.save
      expect(subject.reload.destination).to eq('/needs-stripping')
    end
  end

  describe '.match_for' do
    it 'returns nil if there is no matching rule' do
      expect(RedirectRule.match_for('/someplace', {})).to be_nil
    end

    it 'returns the rule if there is a matching rule' do
      expect(RedirectRule.match_for('/catchy_thingy', {})).to eq(subject)
    end

    context 'for a case sensitive match' do
      let!(:case_sensitive_rule) { create(:redirect_rule, :source_is_case_sensitive => true, :source => '/Case-Does-Matter') }

      it 'returns the rule if it matches the case' do
        expect(RedirectRule.match_for('/Case-Does-Matter', {})).to eq(case_sensitive_rule)
      end

      it 'returns nil if it does not match the case' do
        expect(RedirectRule.match_for('/case-does-matter', {})).to be_nil
      end
    end

    context 'for a case insensitive match' do
      let!(:case_insensitive_rule) { create(:redirect_rule, :source_is_case_sensitive => false, :source => '/Case-Does-Not-Matter') }

      it 'returns the rule if it matches the case' do
        expect(RedirectRule.match_for('/Case-Does-Not-Matter', {})).to eq(case_insensitive_rule)
      end

      it 'returns the rule if it does not match the case' do
        expect(RedirectRule.match_for('/case-does-not-matter', {})).to eq(case_insensitive_rule)
      end
    end

    context 'for a case sensitive regex match' do
      let!(:regex_rule){ create(:redirect_rule_regex, :source_is_case_sensitive => true) }

      it 'returns the rule if it matches the case' do
        expect(RedirectRule.match_for('/new_shiny/from_company', {})).to eq(regex_rule)
      end

      it 'returns nil if it does not match the case' do
        expect(RedirectRule.match_for('/new_SHINY/from_company', {})).to be_nil
      end
    end

    context 'for a case insensitive regex match' do
      let!(:regex_rule){ create(:redirect_rule_regex) }

      it 'returns the rule if it matches the case' do
        expect(RedirectRule.match_for('/new_shiny/from_company', {})).to eq(regex_rule)
      end

      it 'returns the rule if it does not match the case' do
        expect(RedirectRule.match_for('/new_SHINY/from_company', {})).to eq(regex_rule)
      end
    end

    context 'with a rule with one environment condition' do
      before do
        create(:request_environment_rule, :redirect_rule => subject)
      end

      it 'should find the rule if it matches' do
        expect(RedirectRule.match_for('/catchy_thingy', {'SERVER_NAME' => 'example.com'})).to eq(subject)
      end

      it 'should not find the rule if there is no match' do
        expect(RedirectRule.match_for('/catchy_thingy', {'SERVER_NAME' => 'example.ca'})).to be_nil
      end
    end

    context 'with a rule with multiple environment conditions' do
      before do
        create(:request_environment_rule, :redirect_rule => subject)
        create(:request_environment_rule_regex, :redirect_rule => subject)
      end

      it 'should find the rule if it matches' do
        expect(RedirectRule.match_for('/catchy_thingy', {'SERVER_NAME' => 'example.com',
          'QUERY_STRING' => 's=bogus&something=value'})).to eq(subject)
      end

      it 'should not find the rule if there is no match' do
        expect(RedirectRule.match_for('/catchy_thingy', {'SERVER_NAME' => 'example.com',
          "QUERY_STRING" => 's=bogus&something=wrong'})).to be_nil
      end
    end

    context 'with multiple rules with multiple environment conditions' do
      let!(:rule2){ create(:redirect_rule) }
      before do
        create(:request_environment_rule, :redirect_rule => subject)
        create(:request_environment_rule_regex, :redirect_rule => subject)
        create(:request_environment_rule, :redirect_rule => rule2)
        create(:request_environment_rule_regex, :redirect_rule => rule2,
          :environment_value => 'another=value')
      end

      it 'should find the rule if it matches' do
        expect(RedirectRule.match_for('/catchy_thingy', {'SERVER_NAME' => 'example.com',
          'QUERY_STRING' => 's=bogus&something=value'})).to eq(subject)
      end

      it 'should find the other rule if it matches' do
        expect(RedirectRule.match_for('/catchy_thingy', {'SERVER_NAME' => 'example.com',
          'QUERY_STRING' => 's=bogus&another=value'})).to eq(rule2)
      end

      it 'should not find the rule if there is no match' do
        expect(RedirectRule.match_for('/catchy_thingy', {'SERVER_NAME' => 'example.com',
          "QUERY_STRING" => 's=bogus&something=wrong'})).to be_nil
      end
    end

    context 'with a regex rule that also matches an exact string match' do
      let!(:regex_rule){ create(:redirect_rule_regex, :source => '[A-Za-z0-9]_thingy') }

      it 'should return the exact match' do
        expect(RedirectRule.match_for('/catchy_thingy', {})).to eq(subject)
      end
    end
  end

  describe '.destination_for' do
    let!(:regex_rule) { create(:redirect_rule_regex) }

    it 'should find a regex match' do
      expect(RedirectRule.destination_for('/new_shiny/from_company', {})).to eq('http://www.example.com/news/from_company')
    end

    it 'should find a string match' do
      expect(RedirectRule.destination_for('/catchy_thingy', {})).to eq('http://www.example.com/products/1')
    end

    it 'should return nil if there is no matching rule' do
      expect(RedirectRule.destination_for('/someplace', {})).to be_nil
    end
  end

  describe '#evaluated_destination_for' do
    let(:regex_rule) { create(:redirect_rule_regex) }

    it 'returns the destination for a non regex rule' do
      expect(subject.evaluated_destination_for('/catchy_thingy')).to eq('http://www.example.com/products/1')
    end

    it 'returns the evaluated destination for a regex rule' do
      expect(regex_rule.evaluated_destination_for('/new_shiny/from_company')).to eq('http://www.example.com/news/from_company')
    end
  end
end
