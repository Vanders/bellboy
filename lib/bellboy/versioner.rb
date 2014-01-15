# encoding: utf-8
require 'bellboy'
require 'databag_version'

module Bellboy
  # Process any data bag templates into versioned data bag items
  class Versioner
    class << self
      def version(berksfile, options = {})
        local_sources = Bellboy.berks_sources(berksfile)

        local_sources.each do |source|
          Bellboy.logger.debug "Source: #{source.cached_cookbook.path}"

          DatabagVersion.process_all(options[:verbose], "#{source.cached_cookbook.path}/data_bags") if
            Dir.exists?("#{source.cached_cookbook.path}/data_bags")
        end
      end
    end
  end
end
