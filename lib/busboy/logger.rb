module Busboy
  LOG_LEVEL_NONE = 0
  LOG_LEVEL_INFO = 1
  LOG_LEVEL_DEBUG = 2

  class Logger
    def initialize(options={})
      @loglevel = options[:verbose] ? Busboy::LOG_LEVEL_DEBUG : Busboy::LOG_LEVEL_INFO
    end

    # Output a normal informational message
    def log(message)
      puts(message) unless @loglevel < Busboy::LOG_LEVEL_INFO 
    end

    # Output a debug message
    def debug(message)
      puts(message) unless @loglevel < Busboy::LOG_LEVEL_DEBUG
    end
    alias_method :verbose, :debug

  end
end

