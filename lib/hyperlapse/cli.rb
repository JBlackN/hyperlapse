require 'thor'

module Hyperlapse
  class CLI < Thor
    desc 'init FILE(S)',
         'Extracts path from FILE(S) in KML format '\
         'and initializes new Hyperlapse.'
    def init(*files)
      kml = Hyperlapse::Parser.new(files)
      Hyperlapse::PathConfig.new(nil, kml.to_h)
    end

    desc 'config [ID]',
         'Lets you update path (specified by ID or interactive) '\
         'configuration.'
    option :app, type: :boolean, default: nil
    option :api_key, default: nil
    option :fps, default: nil
    option :limit, default: nil
    option :where, type: :boolean, default: nil
    def config(id = nil)
      Hyperlapse::Config.new(id, options).handle
    end

    desc 'download [ID]',
         'Downloads images from Google API for a path specified by id or '\
         'by path specified by from/to parameters using interactive mode.'
    option :optimize, type: :boolean, default: nil
    def download(id = nil) # FIXME: Multiple days
      fail 'API key not set.' unless Hyperlapse::AppConfig.check_api_key
      config_manager = Hyperlapse::PathConfig.new(id)
      Hyperlapse::Downloader.new(config_manager, options).download
    end

    desc 'generate [ID]',
         'Generates hyperlapse for a path specified by id or '\
         'by path specified by from/to parameters using interactive mode.'
    def generate(id = nil)
      config_manager = Hyperlapse::PathConfig.new(id)
      Hyperlapse::Generator.new(config_manager).generate
    end

    desc 'clear [ID]',
         'Clears files/directories of a path specified by id or '\
         'by path specified by from/to parameters using interactive mode.'
    option :downloads, type: :boolean, default: nil
    option :output, type: :boolean, default: nil
    option :workplace, type: :boolean, default: nil
    def clear(id = nil)
      config_manager = Hyperlapse::PathConfig.new(id)
      Hyperlapse::Cleanser.new(config_manager, options).clear
    end
  end
end
