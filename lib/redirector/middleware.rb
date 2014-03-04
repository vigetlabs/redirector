module Redirector
  class RuleError < StandardError; end

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
        @matched_destination ||= with_optional_silencing do
          RedirectRule.destination_for(request_path, env)
        end
      end

      def with_optional_silencing(&block)
        if Redirector.silence_sql_logs
          ActiveRecord::Base.logger.silence { yield }
        else
          yield
        end
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

      def request_port
        @request_port ||= begin
          if env['HTTP_HOST'].include?(':')
            env['HTTP_HOST'].split(':').last.to_i
          end
        end
      end

      def redirect_response
        [301, {'Location' => redirect_url_string},
          [%{You are being redirected <a href="#{redirect_url_string}">#{redirect_url_string}</a>}]]
      end

      def destination_uri
        URI.parse(matched_destination)
      rescue URI::InvalidURIError
        rule = RedirectRule.match_for(request_path, env)
        raise Redirector::RuleError, "RedirectRule #{rule.id} generated the bad destination: #{matched_destination}"
      end

      def redirect_uri
        destination_uri.tap do |uri|
          uri.scheme ||= 'http'
          uri.host   ||= request_host
          uri.port   ||= request_port if request_port.present?
          uri.query  ||= env['QUERY_STRING'] if Redirector.preserve_query
        end
      end

      def redirect_url_string
        @redirect_url_string ||= redirect_uri.to_s
      end
    end
  end
end
