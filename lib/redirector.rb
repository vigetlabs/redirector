module Redirector
  autoload :Middleware, 'redirector/middleware'
  autoload :RegexAttribute, 'redirector/regex_attribute'

  mattr_accessor :include_query_in_source
  mattr_accessor :preserve_query
  mattr_accessor :silence_sql_logs
  mattr_accessor :ignored_patterns

  def self.active_record_protected_attributes?
    @active_record_protected_attributes ||= Rails.version.to_i < 4 || defined?(ProtectedAttributes)
  end
end

require "redirector/engine"
