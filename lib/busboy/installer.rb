require 'busboy'
require 'faraday'

module Busboy
  class Installer 
    class << self
      def install(berksfile, options = {})
        @busboyfile = options[:busboyfile]

        local_sources = Busboy::berks_sources(berksfile)

        local_sources.each do |source|
          Busboy.logger.debug "Got #{source.cached_cookbook.path}"

          if File.exists?(File.join(source.cached_cookbook.path, @busboyfile))
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
        containerpath = File.join(path, 'data_bags')

        begin
          Dir.mkdir(containerpath) unless Dir.exists?(containerpath)
        rescue SystemCallError => ex
          raise Busboy::DatabagWriteError.new(containerpath), ex
        end

        manifest = File.join(path, @busboyfile)
        begin
          File.read(manifest).split.each do |line|
            databag, item = line.split('/')

            databagpath = File.join(containerpath, databag)
            Dir.mkdir(databagpath) unless Dir.exists?(databagpath)

            itempath = File.join(databagpath, "#{item}.json")
            unless File.exists?(itempath)
              download_item(site, databag, item, itempath)
            else
              Busboy.logger.verbose "Skipping download of #{itempath} as it already exists"
            end

          end

        rescue SystemCallError, IOError => ex
          raise Busboy::DatabagReadError.new(manifest), ex
        end

      end
    end

    def download_item(site, databag, item, itempath)
      location = File.join("#{site[:value]}", 'databags', databag, item)

      Busboy.logger.log "Downloading data bag item #{databag}/#{item} from '#{location}'"

      response = Faraday.get(location)
      if response.success?
        begin
          Busboy.logger.debug "Creating data bag item "#{itempath}"

          item = File.open(itempath, 'w')
          item.write(response.body)
          item.close
        rescue SystemCallError, IOError => ex
          raise Busboy::DatabagWriteError.new(databagpath), ex
        end
      else
        Busboy.logger.log "Failed to download #{location}"
        # Raise an exception?
      end
    end

  end
end

