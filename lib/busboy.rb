require 'berkshelf'

require_relative 'busboy/errors'
require_relative 'busboy/logger'
require_relative 'busboy/versioner'
require_relative 'busboy/installer'
require_relative 'busboy/uploader'

module Busboy
  class << self

    def berks_from_file(filepath)
      Berkshelf::Berksfile.from_file(filepath)  
    end

    attr_accessor :logger

    def berks_sources(berksfile)
      resolver          = Berkshelf.ui.mute { berksfile.resolve(berksfile.sources) }
      #cached_cookbooks  = resolver[:solution]
      local_sources     = resolver[:sources]
    end
  end
end

require_relative 'busboy/cli'
