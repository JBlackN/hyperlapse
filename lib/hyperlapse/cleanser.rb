require 'fileutils'

module Hyperlapse
  class Cleanser
    def initialize(config_manager, options)
      @options = options
      @path_dir = config_manager.path_dir
      @pics_dir = config_manager.pics_dir
      @maps_dir = config_manager.maps_dir
      @empty_dir = config_manager.empty_dir
      @output_dir = config_manager.output_dir
      @pics_scale_dir = config_manager.pics_scale_dir
      @maps_scale_dir = config_manager.maps_scale_dir
      @composite_dir = config_manager.composite_dir
    end

    def clear
      if @options.empty?
        clear_path
      else
        clear_parts
      end
    end

    private

    def clear_path
      FileUtils.rm_rf(@path_dir)
    end

    def clear_parts
      FileUtils.rm_rf(downloads) if @options[:downloads]
      FileUtils.rm_rf(output) if @options[:output]
      FileUtils.rm_rf(workplace) if @options[:workplace]
    end

    def output
      Dir.glob(File.join(@output_dir, '*'))
    end

    def downloads
      [
        Dir.glob(File.join(@maps_dir, '*')),
        Dir.glob(File.join(@pics_dir, '*')),
        Dir.glob(File.join(@empty_dir, '*'))
      ].flatten
    end

    def workplace
      [
        Dir.glob(File.join(@pics_scale_dir, '*')),
        Dir.glob(File.join(@maps_scale_dir, '*')),
        Dir.glob(File.join(@composite_dir, '*'))
      ].flatten
    end
  end
end
