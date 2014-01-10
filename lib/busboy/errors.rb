module Busboy
  class BusboyError < StandardError
  end

  class BusboyIOError < BusboyError
    def initialize(filepath)
      @filepath = File.dirname(File.expand_path(filepath)) rescue filepath
    end
  end

  class DatabagWriteError < BusboyIOError
    def to_s
      "IO error writing to #{@filepath}"
    end
  end

  class DatabagReadError < BusboyIOError
    def to_s
      "IO error reading from #{@filepath}"
    end
  end

  class ChefConnectionError < BusboyError
  end

end

