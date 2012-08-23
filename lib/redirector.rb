module Redirector
  autoload :Middleware, 'redirector/middleware'
  autoload :RegexAttribute, 'redirector/regex_attribute'
end

require "redirector/engine"
