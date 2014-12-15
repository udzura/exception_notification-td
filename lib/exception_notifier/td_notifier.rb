require "exception_notification/td/version"

require "td-logger"

module ExceptionNotifier
  class TdNotifier
    def initialize(options)
      @database   = options.delete(:database)
      @table_name = options.delete(:table_name)
      raise "Please set database and table_name. options: #{options.inspect}" if !@database or !@table_name

      TreasureData::Logger.open(@database, options)
    end
    attr_accessor :td

    def call(exception, options = {})
      TD.event.post(@table_name, exception_to_td_data(exception, options))
    end

    def exception_to_td_data(exception, options)
      params = {
        class: exception.class,
        message: exception.message,
        backtrace: exception.backtrace,
        hostname: (Socket.gethostname rescue nil),
        environment: Rails.env,
      }
      params.merge!(request_env: options[:env]) if options[:env]
      params
    end
  end
end
