require 'goliath/request'

module Goliath
  class API

    class << self
      def middlewares; @middlewares; end
      def use(name, args = nil, &block)
        @middlewares ||= [[::Rack::ContentLength, nil, nil]]
        @middlewares.push([name, args, block])
      end

      def plugins; @plugins || []; end
      def plugin(name, *args)
        @plugins ||= []
        @plugins.push([name, args])
      end
    end

    def call(env)
      Fiber.new {
        begin
          status, headers, response = response(env)
          env[Goliath::Request::ASYNC_CALLBACK].call([status, headers, response])

        rescue Exception => e
          env.logger.error(e.message)
          env.logger.error(e.backtrace.join("\n"))

          env[Goliath::Request::ASYNC_CALLBACK].call([400, {}, {:error => e.message}])
        end
      }.resume

      Goliath::Connection::AsyncResponse
    end

    def options_parser(opts, options)
    end

    def response(env)
      env.logger.error('You need to implement response')
      [400, {}, {:error => 'No response implemented'}]
    end
  end
end
