class RedirectRule < ActiveRecord::Base
  attr_accessible :source, :source_is_regex, :destination, :active
  
  validates :source, :destination, :active, :presence => true
  validates :source_is_regex, :inclusion => { :in => ['0', '1', true, false] }
  validate :source_is_valid_regex

  def self.regex_expression
    case connection.adapter_name
    when 'PostgreSQL'
      ':source ~ redirect_rules.source'
    when /mysql/i
      ':source REGEXP redirect_rules.source = 1'
    end
  end

  def self.match_for(source)
    sql_condition = %q{active = :true AND } +
      %q{((source_is_regex = :false AND source = :source) OR } +
      %Q{(source_is_regex = :true AND #{regex_expression}))}
    where(sql_condition, {:true => true, :false => false, :source => source}).first
  end

  def self.destination_for(source)
    rule = match_for(source)
    rule.destination if rule
  end

  private
  
  def source_is_valid_regex
    if source_is_regex? && source?
      begin
        Regexp.compile(source)
      rescue RegexpError
        errors.add(:source, 'is invalid regex')
      end
    end
  end
end
