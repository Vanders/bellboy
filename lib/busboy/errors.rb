# encoding: utf-8

# Exceptions that are specific to Busboy
module Busboy
  # Base class for all internal Busboy errors
  class BusboyError < StandardError
  end

  # Base for all Read/Write/Create errors
  class BusboyIOError < BusboyError
    def initialize(filepath)
      @filepath = File.dirname(File.expand_path(filepath)) rescue filepath
    end
  end

  # Couldn't create or write to a new data bag item
  class DatabagWriteError < BusboyIOError
    def to_s
      "IO error writing to #{@filepath}"
    end
  end

  # Couldn't read from a manifest
  class DatabagReadError < BusboyIOError
    def to_s
      "IO error reading from #{@filepath}"
    end
  end

  # An error occured during a Chef API call
  class ChefConnectionError < BusboyError
  end
end
