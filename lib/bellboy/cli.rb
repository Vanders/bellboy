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
require 'thor'

module Bellboy
  # Simple CLI. Mirrors the Berkshelf options & commands where possible.
  class Cli < Thor
    def initialize(*args)
      super(*args)

      Bellboy.logger = Bellboy::Logger.new(options)

      if @options[:config]
        unless File.exist?(@options[:config])
          raise ConfigNotFound, @options[:config]
        end
          Berkshelf::Config.set_path(@options[:config])
        end
    end

    class_option :verbose,
      type: :boolean,
      desc: 'Enable verbose output.',
      aliases: '-v'
    class_option :quiet,
      type: :boolean,
      desc: 'Silence all informational output.',
      aliases: '-q',
      default: false
    class_option :config,
      type: :string,
      desc: 'Path to Berkshelf configuration to use.',
      aliases: '-c',
      banner: 'PATH'

    desc 'version', 'Version all databag templates'
    method_option :berksfile,
      type: :string,
      default: Berkshelf::DEFAULT_FILENAME,
      desc: 'Path to a Berksfile to operate off of.',
      aliases: '-b',
      banner: 'PATH'
    def version
      berksfile = Bellboy.berks_from_file(options[:berksfile])

      version_options = options.reverse_merge(verbose: false)

      Bellboy::Versioner.version(berksfile, version_options)
    end

    desc 'install', 'Install databags for all Cookbooks known by Berkshelf'
    method_option :berksfile,
      type: :string,
      default: Berkshelf::DEFAULT_FILENAME,
      desc: 'Path to a Berksfile to operate off of.',
      aliases: '-b',
      banner: 'PATH'
    method_option :bellboyfile,
      type: :string,
      default: Bellboy::DEFAULT_FILENAME,
      desc: 'Path to a Bellboy file to operate off of.',
      aliases: '-d',
      banner: 'PATH'
    def install
      berksfile = Bellboy.berks_from_file(options[:berksfile])
      Bellboy::Installer.install(berksfile, options)
    end

    desc 'upload', 'Upload all databags for all Cookbooks known by Berkshelf'
    method_option :berksfile,
      type: :string,
      default: Berkshelf::DEFAULT_FILENAME,
      desc: 'Path to a Berksfile to operate off of.',
      aliases: '-b',
      banner: 'PATH'
    method_option :bellboyfile,
      type: :string,
      default: Bellboy::DEFAULT_FILENAME,
      desc: 'Path to a Bellboy file to operate off of.',
      aliases: '-d',
      banner: 'PATH'
    def upload
      berksfile = Bellboy.berks_from_file(options[:berksfile])
      Bellboy::Uploader.upload(berksfile, options)
    end

    desc 'list', 'List all databags for all Cookbooks known by Berkshelf'
    method_option :berksfile,
      type: :string,
      default: Berkshelf::DEFAULT_FILENAME,
      desc: 'Path to a Berksfile to operate off of.',
      aliases: '-b',
      banner: 'PATH'
    method_option :bellboyfile,
      type: :string,
      default: Bellboy::DEFAULT_FILENAME,
      desc: 'Path to a Bellboy file to operate off of.',
      aliases: '-d',
      banner: 'PATH'
    method_option :bags,
      type: :boolean,
      desc: 'List only the databags.',
      aliases: '-B',
      default: false
    method_option :json,
      type: :boolean,
      desc: 'Output in JSON format.',
      aliases: '-j',
      default: false
    def list
      berksfile = Bellboy.berks_from_file(options[:berksfile])
      databags = Bellboy.list(berksfile)

      if options[:json]
        puts databags.to_json
      else
        databags.each do |bag, items|
          puts options[:bags] ? bag : "#{bag}:"

          items.each do |item|
            puts "\t#{item}"
          end unless options[:bags]
        end
      end

    end
  end
end
