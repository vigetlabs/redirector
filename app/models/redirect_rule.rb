class RedirectRule < ActiveRecord::Base
  extend Redirector::RegexAttribute
  regex_attribute :source

  has_many :request_environment_rules
  
  attr_accessible :source,
                  :source_is_regex,
                  :destination,
                  :active,
                  :source_is_case_sensitive
  
  validates :source, :destination, :active, :presence => true

  def self.regex_expression
    case connection.adapter_name
    when 'PostgreSQL'
      '(redirect_rules.source_is_case_sensitive = :true AND :source ~ redirect_rules.source) OR '+
      '(redirect_rules.source_is_case_sensitive = :false AND :source ~* redirect_rules.source)'
    when /mysql/i
      '(redirect_rules.source_is_case_sensitive = :true AND :source REGEXP BINARY redirect_rules.source) OR '+
      '(redirect_rules.source_is_case_sensitive = :false AND :source REGEXP redirect_rules.source)'
    end
  end

  def self.match_sql_condition
    <<-SQL
      redirect_rules.active = :true AND
      ((source_is_regex = :false AND redirect_rules.source = :source) OR 
      (source_is_regex = :true AND (#{regex_expression})))
    SQL
  end

  def self.match_for(source, environment)
    where(match_sql_condition.strip, {:true => true, :false => false, :source => source}).detect do |rule|
      rule.request_environment_rules.all? {|env_rule| env_rule.matches?(environment) }
    end
  end

  def self.destination_for(source, environment)
    rule = match_for(source, environment)
    rule.evaluated_destination_for(source) if rule
  end

  def evaluated_destination_for(request_path)
    if source_is_regex? && request_path =~ source_regex
      matches = $~
      number_of_grouped_matches = matches.length - 1
      final_destination = destination.dup

      number_of_grouped_matches.downto(1) do |index|
        final_destination.gsub!(/\$#{index}/, matches[index])
      end

      final_destination
    else
      destination
    end
  end

end
