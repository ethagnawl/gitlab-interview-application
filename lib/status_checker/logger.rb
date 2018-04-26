# frozen_string_literal: true

require "log4r"

module StatusChecker
  class Logger
    def initialize(log_file: "log/status_checker.log", level: :info)
      @log = Log4r::Logger.new("logger")
      @log.add Log4r::FileOutputter.new("filelog", filename: log_file)

      case level
      when :debug
        @log.level = Log4r::DEBUG
      when :info
        @log.level = Log4r::INFO
      when :warn
        @log.level = Log4r::WARN
      when :error
        @log.level = Log4r::ERROR
      when :fatal
        @log.level = Log4r::FATAL
      end
    end

    def debug(message)
      @log.debug(message)
    end

    def info(message)
      @log.info(message)
    end

    def warn(message)
      @log.warn(message)
    end

    def error(message)
      @log.error(message)
    end

    def fatal(message)
      @log.fatal(message)
    end
  end
end
