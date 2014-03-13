module Bellboy
  module BerksfileBellboy

    def self.included(base)
      base.class_eval do
        expose_method :databags
        expose_method :databags_source
      end
    end

    # Add a 'Databags' default location which will be used to resolve databag sources.
    #
    # @example
    #   databags "http://example.com/databags"
    #
    # @param [String] value
    #
    # @return [Berkshelf::Source]
    def databags(api_url)
      @databags = Berkshelf::Source.new(api_url)
    end

    # Get the 'Databags' location which will be used to resolve databag sources.
    #
    # @return [Berkshelf::Source]
    def databags_source
      @databags
    end

  end

  Berkshelf::Berksfile.send(:include, BerksfileBellboy) 
end
