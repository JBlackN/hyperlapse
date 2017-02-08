require 'fileutils' # TODO: Check if needed here
require 'thor'

module Hyperlapse
  class CLI < Thor
    desc 'init FILE(S)',
      'Extracts path from FILE(S) in KML format ' +
      'and initializes new Hyperlapse.'
    def init(*files)
      kml = Hyperlapse::Parser.new(files)
      Hyperlapse::PathConfig.new(nil, kml.to_h)
    end

    desc 'config [ID]',
      'Lets you update path (specified by ID or interactive) configuration.'
    option :app, type: :boolean, default: nil
    option :api_key, default: nil
    option :fps, default: nil
    option :limit, default: nil
    option :where, type: :boolean, default: nil
    def config(id = nil)
      if !options[:app].nil?
        puts "App config location: #{Hyperlapse::APP_DIR}"
      elsif !options[:api_key].nil?
        Hyperlapse::AppConfig.set_api_key(options[:api_key])
      elsif !options[:where].nil?
        config_manager = Hyperlapse::PathConfig.new(id)
        puts "Path config location: #{config_manager.path_dir}"
      else
        config_manager = Hyperlapse::PathConfig.new(id)
        config_manager.print_config
        config_manager.update_config(options)
        config_manager.print_config
      end
    end

    desc 'download [ID]',
      'Downloads images from Google API for a path specified by id ' +
      'or by path specified by from/to parameters using interactive mode.'
    option :optimize, type: :boolean, default: nil
    def download(id = nil) # FIXME: Multiple days
      fail 'API key not set.' unless Hyperlapse::AppConfig.check_api_key
      config_manager = Hyperlapse::PathConfig.new(id)
      Hyperlapse::Downloader.new(config_manager, options).download
    end

    desc 'generate [ID]',
      'Generates hyperlapse for a path specified by id ' +
      'or by path specified by from/to parameters using interactive mode.'
    def generate(id = nil)
      config_manager = Hyperlapse::PathConfig.new(id)
      Hyperlapse::Generator.new(config_manager).generate
    end

    desc 'clear [ID]',
      'Clears files/directories of a path specified by id ' +
      'or by path specified by from/to parameters using interactive mode.'
    option :downloads, type: :boolean, default: nil
    option :output, type: :boolean, default: nil
    option :workplace, type: :boolean, default: nil
    def clear(id = nil)
      config_manager = Hyperlapse::PathConfig.new(id)

      if options.empty?
        FileUtils.rm_rf(config_manager.path_dir)
      else
        output = Dir.glob(File.join(config_manager.output_dir, '*'))
        downloads = [
          Dir.glob(File.join(config_manager.maps_dir, '*')),
          Dir.glob(File.join(config_manager.pics_dir, '*')),
          Dir.glob(File.join(config_manager.empty_dir, '*'))
        ].flatten
        workplace = [
          Dir.glob(File.join(config_manager.pics_scale_dir, '*')),
          Dir.glob(File.join(config_manager.maps_scale_dir, '*')),
          Dir.glob(File.join(config_manager.composite_dir, '*'))
        ].flatten

        FileUtils.rm_rf(downloads) if options[:downloads]
        FileUtils.rm_rf(output) if options[:output]
        FileUtils.rm_rf(workplace) if options[:workplace]
      end
    end

    desc 'test', 'test'
    def test # FIXME
      puts Hyperlapse::WIDTH
    end
  end
end
