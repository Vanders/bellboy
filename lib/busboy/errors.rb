module Busboy
  class BusboyError < StandardError
  end

  class DatabagWriteError < BusboyError
    def initialize(filepath)
      @filepath = File.dirname(File.expand_path(filepath)) rescue filepath
    end

    def to_s
      "IO error creating databag at #{@filepath}"
    end
  end
end

