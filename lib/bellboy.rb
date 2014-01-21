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
require 'berkshelf'
require 'ridley'

require 'bellboy/mixin/berkshelf.rb'

require 'bellboy/errors'
require 'bellboy/logger'
require 'bellboy/versioner'
require 'bellboy/installer'
require 'bellboy/uploader'

module Bellboy
  DEFAULT_FILENAME = 'Bellboy'

  class << self
    def berks_from_file(filepath)
      begin
        Berkshelf::Berksfile.from_file(filepath)
      rescue Berkshelf::BerksfileNotFound
        Bellboy.logger.log "Berkfile #{filepath} could not be found."
        exit
      end
    end

    attr_accessor :logger

    def berks_sources(berksfile)
      resolver = Berkshelf.ui.mute { berksfile.resolve(berksfile.sources) }
      resolver[:sources]
    end

    def ridley_connection(options = {})
      ridley_options               = options.slice(:ssl)
      ridley_options[:server_url]  = options[:server_url] || Berkshelf::Config.instance.chef.chef_server_url
      ridley_options[:client_name] = options[:client_name] || Berkshelf::Config.instance.chef.node_name
      ridley_options[:client_key]  = options[:client_key] || Berkshelf::Config.instance.chef.client_key
      ridley_options[:ssl]         = { verify: (options[:ssl_verify] || Berkshelf::Config.instance.ssl.verify) }

      unless ridley_options[:server_url].present?
        fail Berkshelf::ChefConnectionError, 'Missing required attribute in your Berkshelf configuration: chef.server_url'
      end

      unless ridley_options[:client_name].present?
        fail Berkshelf::ChefConnectionError, 'Missing required attribute in your Berkshelf configuration: chef.node_name'
      end

      unless ridley_options[:client_key].present?
        fail Berkshelf::ChefConnectionError, 'Missing required attribute in your Berkshelf configuration: chef.client_key'
      end

      Ridley.new(ridley_options)
    end

    def list(berksfile)
      databags = {}

      local_sources = Bellboy.berks_sources(berksfile)

      local_sources.each do |source|
        Bellboy.logger.debug "Source: #{source.cached_cookbook.path}"

        path = File.join(source.cached_cookbook.path, 'data_bags')
        Dir.foreach(path) do |dir|
          subdir = File.join(path, dir)

          next unless File.directory?(subdir)
          next if dir == '.' || dir == '..'

          databags[dir] = []

          Dir.foreach(subdir) do |item|
            next if item == '.' || item == '..'

            databags[dir] << item
          end
        end if Dir.exists?(path)

      end

      databags
    end
  end
end

require_relative 'bellboy/cli'
