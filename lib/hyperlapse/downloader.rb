# frozen_string_literal: false
require 'json'
require 'net/http'
require 'openssl'
require 'open-uri'

module Hyperlapse
  class Downloader
    def initialize(config_manager, options)
      @config = config_manager.config
      @pics_dir = config_manager.pics_dir
      @maps_dir = config_manager.maps_dir
      @empty_dir = config_manager.empty_dir
      @optimize = options[:optimize] unless options.empty?
    end

    def download
      determine_used_frames
      download_frames
    end

    private

    def determine_used_frames
      @frames = []
      i = 0.0
      loop do
        @frames << i.round
        i += @config[:step]
        break if i > @config[:waypoints].length - 1
      end
    end

    def download_frames
      @frames.each_with_index do |index, i|
        puts "#{i + 1}/#{@frames.length}" # TODO: Rewrite

        waypoint = @config[:waypoints][index]
        map_file = File.join(@maps_dir, index.to_s + '.jpg')
        pic_file = File.join(@pics_dir, index.to_s + '.jpg')
        empty_file = File.join(@empty_dir, index.to_s)

        download_frame(waypoint, pic_file, map_file, empty_file)
      end
    end

    def download_frame(waypoint, pic_file, map_file, empty_file)
      unless @optimize ? check_frame(waypoint) : true
        File.open(empty_file, 'w') {}
        return
      end

      download_pic(waypoint, pic_file)
      download_map(waypoint, map_file)
    end

    def check_frame(waypoint)
      path = street_view_metadata_path(waypoint)

      http = Net::HTTP.new(Hyperlapse::API_HOST, 443)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE

      response = JSON.parse(http.get(path).body, symbolize_names: true)
      response.key?(:status) && response[:status] == 'OK'
    end

    def download_pic(waypoint, pic_file)
      return if File.file?(pic_file)
      File.open(pic_file, 'wb') do |f|
        f.write open(street_view_uri(waypoint)).read
      end
    end

    def download_map(waypoint, map_file)
      return if File.file?(map_file)
      File.open(map_file, 'wb') do |f|
        f.write open(map_uri(waypoint)).read
      end
    end

    def street_view_metadata_path(waypoint)
      path = <<~END
        #{Hyperlapse::API_METADATA_PATH}
        ?size=640x360
        &location=#{waypoint[:lat]},#{waypoint[:long]}
        &fov=#{Hyperlapse::FOV}
        &heading=#{waypoint[:head]}
        &pitch=0
        &key=#{Hyperlapse::API_KEY}
      END

      path.delete("\n")
    end

    def street_view_uri(waypoint)
      uri = <<~END
        http://#{Hyperlapse::API_HOST}#{Hyperlapse::API_PICS_PATH}
        ?size=640x360
        &location=#{waypoint[:lat]},#{waypoint[:long]}
        &fov=#{Hyperlapse::FOV}
        &heading=#{waypoint[:head]}
        &pitch=0
        &key=#{Hyperlapse::API_KEY}
      END

      uri.delete("\n")
    end

    def map_uri(waypoint)
      uri = <<~END
        http://#{Hyperlapse::API_HOST}#{Hyperlapse::API_MAPS_PATH}
        ?center=#{waypoint[:lat]},#{waypoint[:long]}
        &zoom=9
        &size=640x360
        &maptype=roadmap
        &markers=color:red
        %7Clabel:R
        %7C#{waypoint[:lat]},#{waypoint[:long]}
        &key=#{Hyperlapse::API_KEY}
      END

      uri.delete("\n")
    end
  end
end
