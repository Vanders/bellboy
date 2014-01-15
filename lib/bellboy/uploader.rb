# encoding: utf-8
require 'bellboy'
require 'JSON'

module Bellboy
  # Push data bags & data bag items to the Chef server
  class Uploader
    class << self
      def upload(berksfile, options = {})
        @bellboyfile = options[:bellboyfile]

        local_sources = Bellboy.berks_sources(berksfile)
        conn = Bellboy.ridley_connection(options)
 
        local_sources.each do |source|
          Bellboy.logger.debug "Source: #{source.cached_cookbook.path}"

          upload_databags(source.cached_cookbook, conn)
        end
      end

      private

      def upload_databags(cookbook, conn)
        Bellboy.logger.verbose "Uploading data bags for #{cookbook.name}"

        path = File.join(cookbook.path, 'data_bags')
        Dir.foreach(path) do |dir|
          # Skip everything that isn't a sub-directory
          subdir = File.join(path, dir)
          next unless File.directory?(subdir)

          # Process every sub-directory (but not current & parent, natch)
          unless dir == '.' || dir == '..'
            begin
              conn.data_bag.create(name: dir) unless conn.data_bag.find(dir)
              manifest = upload_databag_items(conn, File.join(path, dir), dir)

            rescue Ridley::Errors::RidleyError => ex
              raise ChefConnectionError, ex
            end

            create_manifest_file(cookbook.path, dir, manifest)
          end
        end if File.exist?(path)

      end

      def upload_databag_items(conn, path, name)
        manifest = []

        Dir.foreach(path) do |file|
          # Upload all of the JSON files
          if file.match('.json')
            begin
              Bellboy.logger.log("Uploading #{File.join(path, file)}")

              itempath = File.join(path, file)
              begin
                item = JSON.parse(IO.read(itempath))
              rescue SystemCallError, IOError
                raise DatabagReadError, itempath
              end

              data_bag = conn.data_bag.find(name)
              data_bag.item.create(item)

              manifest << item['id']

            rescue Ridley::Errors::RidleyError => ex
              raise ChefConnectionError, ex
            end

          end
        end

        manifest
      end

      def create_manifest_file(path, data_bag, manifest)
        begin
          manifestfile = File.open(File.join(path, @bellboyfile), 'w')

          manifest.each do |item|
            manifestfile.write("#{data_bag}/#{item}\n")
          end

          manifestfile.close

        rescue SystemCallError, IOError => ex
          raise ChefConnectionError, ex
        end
      end
    end
  end
end
