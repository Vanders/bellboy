require 'busboy'

module Busboy
  class Installer 
    class << self
      def install(berksfile, options = {})
        local_sources = Busboy::berks_sources(berksfile)

        local_sources.each do |source|
          Busboy.logger.debug "Got #{source.cached_cookbook.path}"

          #if Dir.exists?("#{source.cached_cookbook.path}/data_bags")
          #  DatabagVersion.process_all(false, "#{source.cached_cookbook.path}/data_bags")

          if File.exists?("#{source.cached_cookbook.path}/Busboy")
            site = berksfile.locations.select { |loc| loc[:type] == :site }.first

            unless site.nil?
              download_databags(source, site)
            else
              raise Berkshelf::InvalidChefAPILocation
            end
          end

        end
      end

      def download_databags(source, site)
        Busboy.logger.debug "Downloading databags for #{source.cached_cookbook.path}"
      end
    end

  end
end

