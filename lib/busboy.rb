# encoding: utf-8
require 'berkshelf'
require 'ridley'

require_relative 'busboy/errors'
require_relative 'busboy/logger'
require_relative 'busboy/versioner'
require_relative 'busboy/installer'
require_relative 'busboy/uploader'

module Busboy
  DEFAULT_FILENAME = 'Busboy'

  class << self
    def berks_from_file(filepath)
      begin
        Berkshelf::Berksfile.from_file(filepath)
      rescue Berkshelf::BerksfileNotFound
        Busboy.logger.log "Berkfile #{filepath} could not be found."
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
  end
end

require_relative 'busboy/cli'
