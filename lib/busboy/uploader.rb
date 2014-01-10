require 'busboy'

module Busboy
  class Uploader 
    class << self
      def upload(berksfile, options={})
        Busboy.logger.debug 'upload all the things'
      end
    end

  end
end

