module Redirector
  autoload :Middleware, 'redirector/middleware'
  autoload :RegexAttribute, 'redirector/regex_attribute'
  
  mattr_accessor :include_query_in_source
end

require "redirector/engine"
