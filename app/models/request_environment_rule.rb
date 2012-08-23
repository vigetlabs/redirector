class RequestEnvironmentRule < ActiveRecord::Base
  extend Redirector::RegexAttribute
  regex_attribute :environment_value
  
  belongs_to :redirect_rule

  attr_accessible :redirect_rule_id,
                  :environment_key_name,
                  :environment_value,
                  :environment_value_is_regex,
                  :environment_value_is_case_sensitive

  validates :redirect_rule_id, :environment_key_name, :environment_value, :presence => true

  def matches?(environment)
    if environment_value_is_regex?
      environment[environment_key_name] && environment[environment_key_name] =~ environment_value_regex
    else
      environment[environment_key_name] == environment_value
    end
  end

end
