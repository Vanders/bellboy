# encoding: utf-8

# Exceptions that are specific to Bellboy
module Bellboy
  # Base class for all internal Bellboy errors
  class BellboyError < StandardError
  end

  # Base for all Read/Write/Create errors
  class BellboyIOError < BellboyError
    def initialize(filepath)
      @filepath = File.dirname(File.expand_path(filepath)) rescue filepath
    end
  end

  # Couldn't create or write to a new data bag item
  class DatabagWriteError < BellboyIOError
    def to_s
      "IO error writing to #{@filepath}"
    end
  end

  # Couldn't read from a manifest
  class DatabagReadError < BellboyIOError
    def to_s
      "IO error reading from #{@filepath}"
    end
  end

  # Base for all API errors
  class BellboyAPIError < BellboyError
    def initialize(location)
      @location = location
    end
  end

  # An error occured during a Chef API call
  class ChefConnectionError < BellboyAPIError
  end

  # An error occured during a Bellboy API call
  class DatabagAPIError < BellboyAPIError
    def to_s
      "Databag API call failed for #{@location}"
    end
  end
end
