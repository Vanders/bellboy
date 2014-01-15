# encoding: utf-8

module Bellboy
  LOG_LEVEL_NONE = 0
  LOG_LEVEL_INFO = 1
  LOG_LEVEL_DEBUG = 2

  # Simple stdout logger
  class Logger
    def initialize(options = {})
      @loglevel = level(options)
    end

    # Output a normal informational message
    def log(message)
      puts(message) unless @loglevel < Bellboy::LOG_LEVEL_INFO
    end

    # Output a debug message
    def debug(message)
      puts(message) unless @loglevel < Bellboy::LOG_LEVEL_DEBUG
    end
    alias_method :verbose, :debug

    private

    def level(options)
      if options[:quiet]
        Bellboy::LOG_LEVEL_NONE
      elsif options[:verbose]
        Bellboy::LOG_LEVEL_DEBUG
      else
        Bellboy::LOG_LEVEL_INFO
      end
    end
  end
end
