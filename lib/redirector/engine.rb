module Redirector
  class Engine < ::Rails::Engine
    config.redirector = ActiveSupport::OrderedOptions.new

    initializer "redirector.add_middleware" do |app|
      app.middleware.insert_before(Rack::Lock, Redirector::Middleware)
    end

    initializer "redirector.apply_options" do |app|
      Redirector.include_query_in_source = app.config.redirector.include_query_in_source || false
    end
  end
end
