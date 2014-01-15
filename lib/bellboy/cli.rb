# encoding: utf-8
require 'bellboy'
require 'thor'

module Bellboy
  # Simple CLI. Mirrors the Berkshelf options & commands where possible.
  class Cli < Thor
    def initialize(*args)
      super(*args)

      Bellboy.logger = Bellboy::Logger.new(options)
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
  end
end
