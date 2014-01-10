require 'busboy'
require 'faraday'

module Busboy
  class Installer 
    class << self
      def install(berksfile, options = {})
        local_sources = Busboy::berks_sources(berksfile)

        local_sources.each do |source|
          Busboy.logger.debug "Got #{source.cached_cookbook.path}"

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
        Busboy.logger.log "Downloading databags for #{source.cached_cookbook.name}"

        path = source.cached_cookbook.path

        begin
          Dir.mkdir(File.join(path, 'data_bags'))
        rescue SystemCallError => ex
          throw Busboy::DatabagWriteError(path), ex
        end

        begin
          IO.read("#{path}/Busboy").split.each do |line|

            databag, item = line.split('/')
            location = File.join("#{site[:value]}", 'databags', databag, item)

            Busboy.logger.log "Downloading data bag item #{databag}/#{item} from '#{location}'"

            response = Faraday.get(location)
            if response.success?
              begin
                databagpath = File.join(path, 'data_bags', databag)
                Dir.mkdir(databagpath)

                itempath = File.join(databagpath, "#{item}.json")
                Busboy.logger.debug "Creating data bag item "#{itempath}"

                item = File.open(itempath, 'w')
                item.write(response.body)
                item.close
              rescue IOError => ex
                raise Busboy::DatabagWriteError(databagpath), ex
              end
            else
              Busboy.logger.log "Failed to download #{location}"
              # Raise an exception?
            end
          end
        rescue IOError => ex
          raise Busboy::DatabagReadError, ex
        end

      end
    end

  end
end

