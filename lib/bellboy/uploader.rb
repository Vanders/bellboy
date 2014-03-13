# encoding: utf-8
#
# Copyright 2014 Dyn Inc.
#
# Authors: Kristian Van Der Vliet <kvandervliet@dyn.com>
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
require 'bellboy'
require 'json'

module Bellboy
  # Push data bags & data bag items to the Chef server
  class Uploader
    class << self
      def upload(berksfile, options = {})
        @bellboyfile = options[:bellboyfile]

        local_sources = Bellboy.berks_sources(berksfile)
        conn = Bellboy.ridley_connection(options)
 
        local_sources.each do |source|
          Bellboy.logger.debug "Source: #{source.path}"

          upload_databags(source, conn)
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
              conn.data_bag.create(name: dir)
            rescue Ridley::Errors::HTTPConflict
              Bellboy.logger.verbose "Skipped creation of data bag #{dir}"
            rescue Ridley::Errors::RidleyError => ex
              raise ChefConnectionError, ex
            else
              Bellboy.logger.verbose "Created new data bag #{dir}"
            end 

            manifest = upload_databag_items(conn, File.join(path, dir), dir)

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
