module MarkMapper
  module Middleware
    # Usage:
    #
    #   config.middleware.insert_after \
    #     ActionDispatch::Callbacks,
    #     MarkMapper::Middleware::IdentityMap
    #
    # You have to insert after callbacks so the entire request is wrapped.
    class IdentityMap
      class Body
        extend Forwardable
        def_delegator :@target, :each

        def initialize(target, original)
          @target   = target
          @original = original
        end

        def close
          @target.close if @target.respond_to?(:close)
        ensure
          MarkMapper::Plugins::IdentityMap.enabled = @original
          MarkMapper::Plugins::IdentityMap.clear
        end
      end

      def initialize(app)
        @app = app
      end

      def call(env)
        MarkMapper::Plugins::IdentityMap.clear
        enabled = MarkMapper::Plugins::IdentityMap.enabled
        MarkMapper::Plugins::IdentityMap.enabled = true
        status, headers, body = @app.call(env)
        [status, headers, Body.new(body, enabled)]
      end
    end
  end
end
