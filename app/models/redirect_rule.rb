class RedirectRule < ActiveRecord::Base
  extend Redirector::RegexAttribute
  regex_attribute :source

  has_many :request_environment_rules, :inverse_of => :redirect_rule, :dependent => :destroy

  attr_accessible :source,
                  :source_is_regex,
                  :destination,
                  :active,
                  :source_is_case_sensitive,
                  :request_environment_rules_attributes if Redirector.active_record_protected_attributes?

  accepts_nested_attributes_for :request_environment_rules, :allow_destroy => true, :reject_if => :all_blank

  validates :source, :destination, :presence => true

  # Not working with rails 5.0.1
  if Rails.version.to_i < 5
    validates :active, :inclusion => { :in => ['0', '1', true, false] }
  end

  before_save :strip_source_whitespace, :strip_destination_whitespace

  def self.regex_expression
    if connection_mysql?
      '(redirect_rules.source_is_case_sensitive = :true AND CAST(:source AS BINARY) REGEXP BINARY redirect_rules.source) OR '+
      '(redirect_rules.source_is_case_sensitive = :false AND :source REGEXP redirect_rules.source)'
    elsif connection_sqlite?
      '(redirect_rules.source_is_case_sensitive = :true AND :source REGEXP redirect_rules.source COLLATE BINARY) OR '+
      '(redirect_rules.source_is_case_sensitive = :false AND :source REGEXP redirect_rules.source)'
    else
      '(redirect_rules.source_is_case_sensitive = :true AND :source ~ redirect_rules.source) OR '+
      '(redirect_rules.source_is_case_sensitive = :false AND :source ~* redirect_rules.source)'
    end
  end

  def self.match_sql_condition
    <<-SQL
      redirect_rules.active = :true AND
      ((source_is_regex = :false AND source_is_case_sensitive = :false AND LOWER(redirect_rules.source) = LOWER(:source)) OR
      (source_is_regex = :false AND source_is_case_sensitive = :true AND #{'BINARY' if connection_mysql?} redirect_rules.source = :source #{'COLLATE BINARY' if connection_sqlite?}) OR
      (source_is_regex = :true AND (#{regex_expression})))
    SQL
  end

  def self.match_for(source, environment)
    match_scope = where(match_sql_condition.strip, {:true => true, :false => false, :source => source})
    match_scope = match_scope.order(Arel.sql('redirect_rules.source_is_regex ASC, LENGTH(redirect_rules.source) DESC'))
    match_scope = match_scope.includes(:request_environment_rules)
    match_scope = match_scope.references(:request_environment_rules) if Rails.version.to_i == 4
    match_scope.detect do |rule|
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
        final_destination.gsub!(/\$#{index}/, matches[index].to_s)
      end

      final_destination
    else
      destination
    end
  end

  private

  def self.connection_mysql?
    connection.adapter_name.downcase.include?('mysql')
  end

  def self.connection_sqlite?
    connection.adapter_name.downcase.include?('sqlite')
  end

  def strip_source_whitespace
    self.source = self.source.strip
  end

  def strip_destination_whitespace
    self.destination = self.destination.strip
  end

end
