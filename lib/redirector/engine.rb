module Redirector
  class Engine < ::Rails::Engine
    initializer "redirector.add_middleware" do |app|
      app.middleware.insert_before(Rack::Lock, Redirector::Middleware)
    end
  end
end
