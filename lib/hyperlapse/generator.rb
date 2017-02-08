# frozen_string_literal: false
module Hyperlapse
  class Generator
    def initialize(config_manager)
      @config = config_manager.config
      @pics_dir = config_manager.pics_dir
      @maps_dir = config_manager.maps_dir
      @empty_dir = config_manager.empty_dir
      @output_dir = config_manager.output_dir
      @pics_scale_dir = config_manager.pics_scale_dir
      @maps_scale_dir = config_manager.maps_scale_dir
      @composite_dir = config_manager.composite_dir
    end

    def generate
      fail 'Downloads aren\'t complete.' unless downloads_ok?
      scale_pics
      scale_maps
      place_maps_over_pics
      generate_video
    end

    private

    def downloads_ok?
      empty_count = get_files(@empty_dir).length
      pic_count = get_files(@pics_dir).length + empty_count
      map_count = get_files(@maps_dir).length + empty_count
      waypoint_count = [@config[:limit], @config[:waypoints].length].min

      pic_count == waypoint_count && map_count == waypoint_count
    end

    def scale_pics
      pics = get_files(@pics_dir)
      pics.each do |pic|
        input = File.join(@pics_dir, pic)
        output = File.join(@pics_scale_dir, pic)
        width = Hyperlapse::WIDTH
        height = Hyperlapse::HEIGHT
        command = "convert #{input} -resize #{width}x#{height}! #{output}"

        ok = File.file?(output) ? true : system(command)
        fail "Error scaling pic: #{pic}." unless ok
      end
    end

    def scale_maps
      maps = get_files(@maps_dir)
      maps.each do |map|
        input = File.join(@maps_dir, map)
        output = File.join(@maps_scale_dir, map)
        width = (Hyperlapse::WIDTH * Hyperlapse::MAP_SCALE).round
        height = (Hyperlapse::HEIGHT * Hyperlapse::MAP_SCALE).round
        command = "convert #{input} -resize #{width}x#{height}! #{output}"

        ok = File.file?(output) ? true : system(command)
        fail "Error scaling map: #{map}." unless ok
      end
    end

    def place_maps_over_pics
      images = get_files(@pics_dir)
      images.each do |image|
        map = File.join(@maps_scale_dir, image)
        pic = File.join(@pics_scale_dir, image)
        output = File.join(@composite_dir, image)
        map_pos = Hyperlapse::MAP_POS
        command = "composite -gravity #{map_pos} #{map} #{pic} #{output}"

        ok = File.file?(output) ? true : system(command)
        fail "Error placing #{map} over #{pic}." unless ok
      end
    end

    def generate_video
      input = File.join(@composite_dir, '%d.jpg')
      output = File.join(@output_dir, 'out.mp4')
      command = <<~END
        ffmpeg -f image2 -framerate #{@config[:fps]} -i #{input} #{output}
      END

      ok = system(command.chomp)
      fail 'Error generating video.' unless ok
    end

    def get_files(dir)
      Dir.entries(dir).select do |entry|
        entry_path = File.join(dir, entry)
        File.file?(entry_path)
      end
    end
  end
end
