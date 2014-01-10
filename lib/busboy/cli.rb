require 'busboy'
require 'thor'

module Busboy
  class Cli < Thor

    def initialize(*args)
      super(*args)

      Busboy.logger = Busboy::Logger.new(options)
    end

    class_option :verbose,
      type: :boolean,
      desc: 'Enable verbose output',
      aliases: '-v'

    desc "version", "Version all databag templates"
    method_option :berksfile,
      type: :string,
      default: Berkshelf::DEFAULT_FILENAME,
      desc: 'Path to a Berksfile to operate off of.',
      aliases: '-b',
      banner: 'PATH'
    def version
      berksfile = Busboy::berks_from_file(options[:berksfile])

      version_options = options.reverse_merge(verbose: false)

      Busboy::Versioner.version(berksfile, version_options)
    end

    desc "install", "Install databags for all Cookbooks known by Berkshelf"
    method_option :berksfile,
      type: :string,
      default: Berkshelf::DEFAULT_FILENAME,
      desc: 'Path to a Berksfile to operate off of.',
      aliases: '-b',
      banner: 'PATH'
    method_option :busboyfile,
      type: :string,
      default: Busboy::DEFAULT_FILENAME,
      desc: 'Path to a Busboy file to operate off of.',
      aliases: '-d',
      banner: 'PATH'
    def install
      berksfile = Busboy::berks_from_file(options[:berksfile])
      Busboy::Installer.install(berksfile, options)
    end

    desc "upload", "Upload all databags for all Cookbooks known by Berkshelf"
    method_option :berksfile,
      type: :string,
      default: Berkshelf::DEFAULT_FILENAME,
      desc: 'Path to a Berksfile to operate off of.',
      aliases: '-b',
      banner: 'PATH'
    def upload
      berksfile = Busboy::berks_from_file(options[:berksfile])
      Busboy::Uploader.upload(berksfile, options)
    end

  end
end
