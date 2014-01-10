require 'busboy'

module Busboy
  class Installer 
    class << self
      def install(berksfile, options = {})
        Busboy.logger.log('install all the things')
        Busboy.logger.debug('debug all the installed things')
        Busboy.logger.verbose('verbose all the installed things')
      end
    end

  end
end

