module Redirector
  class Middleware
    def initialize(application)
      @application = application
    end
    
    def call(environment)
      Responder.new(@application, environment).response
    end
    
    class Responder
      attr_reader :app, :env

      def initialize(application, environment)
        @app = application
        @env = environment
      end

      def response
        if redirect?
          redirect_response
        else
          app.call(env)
        end
      end

      private
      
      def redirect?
        matched_destination.present?
      end
      
      def matched_destination
        @matched_destination ||= RedirectRule.destination_for(request_path, env)
      end

      def request_path
        if Redirector.include_query_in_source
          env['ORIGINAL_FULLPATH']
        else
          env['PATH_INFO']
        end
      end
      
      def request_host
        env['HTTP_HOST'].split(':').first
      end

      def redirect_response
        [301, {'Location' => redirect_url_string}, 
          %{You are being redirected <a href="#{redirect_url_string}">#{redirect_url_string}</a>}]
      end

      def destination_uri
        URI.parse(matched_destination)
      end

      def redirect_uri
        destination_uri.tap do |uri|
          uri.scheme ||= 'http'
          uri.host   ||= request_host
        end
      end
      
      def redirect_url_string
        @redirect_url_string ||= redirect_uri.to_s
      end
    end
  end
end
