module Bellboy
  module BerksfileBellboy

    def self.included(base)
      base.class_eval do
        expose_method :databags
      end
    end

    # Add a 'Databags' default location which will be used to resolve databag sources.
    #
    # @example
    #   databags "http://example.com/databags"
    #
    # @param [String] value
    #
    # @return [Hash]
    def databags(value)
      add_location(:databags, value)
    end

  end

  Berkshelf::Berksfile.send(:include, BerksfileBellboy) 
end
