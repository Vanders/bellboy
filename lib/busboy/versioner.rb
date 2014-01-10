require 'busboy'
require 'databag_version'

module Busboy
  class Versioner
    class << self
      def version(berksfile, options = {})
        local_sources = Busboy::berks_sources(berksfile)

        local_sources.each do |source|
          Busboy.logger.debug "Got #{source.cached_cookbook.path}"

          DatabagVersion.process_all(options[:verbose], "#{source.cached_cookbook.path}/data_bags") if
            Dir.exists?("#{source.cached_cookbook.path}/data_bags")
        end
      end
    end
  end
end

