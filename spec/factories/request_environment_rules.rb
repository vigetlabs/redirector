# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :request_environment_rule do
    redirect_rule
    environment_key_name "SERVER_NAME"
    environment_value "example.com"
    
    factory :request_environment_rule_regex do
      environment_key_name "QUERY_STRING"
      environment_value "something=value"
      environment_value_is_regex true
    end
  end
end
