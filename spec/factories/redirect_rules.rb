# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :redirect_rule do
    active true
    source_is_regex false
    source '/catchy_thingy'
    destination 'http://www.example.com/products/1'
    
    factory :redirect_rule_regex do
      source_is_regex true
      source '[A-Za-z0-9_]+shiny\/([A-Za-z0-9_]+)'
      destination 'http://www.example.com/news/$1'
    end
  end
end
