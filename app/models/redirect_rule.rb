class RedirectRule < ActiveRecord::Base
  extend Redirector::RegexAttribute
  regex_attribute :source

  has_many :request_environment_rules
  
  attr_accessible :source, :source_is_regex, :destination, :active
  
  validates :source, :destination, :active, :presence => true

  def self.regex_expression
    case connection.adapter_name
    when 'PostgreSQL'
      ':source ~ redirect_rules.source'
    when /mysql/i
      ':source REGEXP redirect_rules.source = 1'
    end
  end

  def self.match_sql_condition
    <<-SQL
      active = :true AND
      ((source_is_regex = :false AND source = :source) OR 
      (source_is_regex = :true AND #{regex_expression}))
    SQL
  end

  def self.match_for(source, environment)
    where(match_sql_condition.strip, {:true => true, :false => false, :source => source}).detect do |rule|
      rule.request_environment_rules.all? {|env_rule| env_rule.matched?(environment) }
    end
  end

  def self.destination_for(source, environment)
    rule = match_for(source, environment)
    rule.destination if rule
  end

end
