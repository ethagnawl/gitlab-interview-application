# frozen_string_literal: true

require "log4r"

module StatusChecker
  class Logger
    attr_accessor :log

    def initialize(level: :error)
      @log = Log4r::Logger.new("logger")
      @log.add Log4r::Outputter.stderr

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

      @log
    end
  end
end
