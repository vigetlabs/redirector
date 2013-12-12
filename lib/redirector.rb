module Redirector
  autoload :Middleware, 'redirector/middleware'
  autoload :RegexAttribute, 'redirector/regex_attribute'

  mattr_accessor :include_query_in_source
  mattr_accessor :silence_sql_logs

  def self.active_record_protected_attributes?
    @active_record_protected_attributes ||= Rails.version.to_i < 4 || !!defined?(ProtectedAttrbiutes)
  end
end

# Ensure `ProtectedAttributes` gem gets required if it is available before the `Version` class gets loaded
unless Redirector.active_record_protected_attributes?
  Redirector.remove_instance_variable(:@active_record_protected_attributes)
  begin
    require 'protected_attributes'
  rescue LoadError; end # will rescue if ProtectedAttributes gem is not available
end

require "redirector/engine"
