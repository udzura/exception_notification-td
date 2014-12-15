require "exception_notification/td/version"

require "td-logger"

module ExceptionNotifier
  class TdNotifier
    BACKTRACE_LIMIT_DEFAULT = 10

    def initialize(options)
      @table_name = options.delete(:table_name)
      @backtrace_limit = options.delete(:backtrace_limit) || BACKTRACE_LIMIT_DEFAULT
      raise "Please set table_name. options: #{options.inspect}" unless @table_name

      unless defined? TreasureData::Logger::Agent::Rails
        @database = options.delete(:database)
        raise "Please set database. options: #{options.inspect}" unless @database
        TreasureData::Logger.open(@database, options)
      end
    end

    def call(exception, options = {})
      TD.event.post(@table_name, exception_to_td_data(exception, options))
    end

    private
    def request_klass
      @request_klass ||= if defined?(ActionDispatch::Request)
                           ActionDispatch::Request
                         else
                           require 'rack/request'
                           Rack::Request
                         end
    rescue LoadError, NameError
      warn "ExceptionNotification::Td is designed to be used with Rack-based apps. Skip some of features."
      nil
    end

    def exception_to_td_data(exception, options)
      backtrace = exception.backtrace ? exception.backtrace[0, @backtrace_limit] : []
      params = {
        class: exception.class.to_s,
        message: exception.message,
        backtrace: backtrace,
        hostname: (Socket.gethostname rescue nil),
        environment: Rails.env,
      }
      if request_klass && options[:env]
        request = request_klass.new(options[:env])
        params.merge!(
          method: request.request_method,
          request_url: request.url,
          cookies: request.cookies,
          referer: request.referer,
        )
        params[:post_body] = request.body unless request.get?
      end
      params
    end
  end
end
