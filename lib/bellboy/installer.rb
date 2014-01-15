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
require 'faraday'

module Bellboy
  # Downloads data bags from the remote API for any Cookbook that contains a
  # Bellboy manifest.
  class Installer
    class << self
      def install(berksfile, options = {})
        @bellboyfile = options[:bellboyfile]

        local_sources = Bellboy.berks_sources(berksfile)

        local_sources.each do |source|
          Bellboy.logger.debug "Source: #{source.cached_cookbook.path}"

          if File.exists?(File.join(source.cached_cookbook.path, @bellboyfile))
            site = berksfile.locations.select { |loc| loc[:type] == :site }.first

            fail Berkshelf::InvalidChefAPILocation if site.nil?

            download_databags(source, site)
          end

        end
      end

      private

      def download_databags(source, site)
        Bellboy.logger.log "Downloading databags for #{source.cached_cookbook.name}"

        path = source.cached_cookbook.path
        containerpath = File.join(path, 'data_bags')

        begin
          Dir.mkdir(containerpath) unless Dir.exists?(containerpath)
        rescue SystemCallError => ex
          raise Bellboy::DatabagWriteError.new(containerpath), ex
        end

        manifest = File.join(path, @bellboyfile)
        begin
          File.read(manifest).split.each do |line|
            databag, item = line.split('/')

            databagpath = File.join(containerpath, databag)
            Dir.mkdir(databagpath) unless Dir.exists?(databagpath)

            itempath = File.join(databagpath, "#{item}.json")
            if File.exists?(itempath)
              Bellboy.logger.verbose "Skipping download of #{itempath} as it already exists"
            else
              download_item(site, databag, item, itempath)
            end

          end

        rescue SystemCallError, IOError => ex
          raise Bellboy::DatabagReadError.new(manifest), ex
        end
      end

      def download_item(site, databag, item, itempath)
        location = File.join("#{site[:value]}", 'databags', databag, item)

        Bellboy.logger.log "Downloading data bag item #{databag}/#{item} from '#{location}'"

        response = Faraday.get(location)
        if response.success?
          begin
            Bellboy.logger.debug "Creating data bag item #{itempath}"

            item = File.open(itempath, 'w')
            item.write(response.body)
            item.close
          rescue SystemCallError, IOError => ex
            raise Bellboy::DatabagWriteError.new(databagpath), ex
          end
        else
          Bellboy.logger.log "Failed to download #{location}"
          fail Bellboy::DatabagAPIError, location
        end
      end
    end
  end
end
