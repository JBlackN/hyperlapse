# frozen_string_literal: false
require 'digest'
require 'json'

module Hyperlapse
  class Parser
    NAMES_PATTERN = %r{
      <Placemark>.*\r?\n
      .*<name>(.+)<\/name>.*\r?\n
      (?:.*\r?\n)?
      .*<Point>
    }x

    COORDS_PATTERN = %r{
      <LineString>.*\r?\n
      .*\r?\n
      .*<coordinates>(.+)<\/coordinates>\r?\n
      .*<\/LineString>
    }x

    def initialize(files)
      error unless files_ok?(files)

      @coords = []

      determine_from_to(files)
      files.each { |file| parse(file) }
      calculate_headings
      calculate_id(files)
    end

    def to_h
      { id: @id, from: @from, to: @to, waypoints: @coords }
    end

    private

    def files_ok?(files)
      files.is_a?(Array) && !files.empty? && files.map do |f|
        File.file?(f) && File.readlines(f)[1] =~ /^<kml.*>$/
      end.all?
    end

    def determine_from_to(files)
      first_file = IO.binread(files[0])
      last_file = IO.binread(files[-1])

      @from = first_file.scan(NAMES_PATTERN).flatten[0]
      @to = last_file.scan(NAMES_PATTERN).flatten[-1]

      @from.force_encoding('utf-8')
      @to.force_encoding('utf-8')
    end

    def parse(file)
      kml = IO.binread(file)
      paths = kml.scan(COORDS_PATTERN).flatten

      paths.each do |path|
        coords = path.split(' ').map { |triplet| triplet.split(',')[0..1] }
        coords.each do |pair|
          @coords << [:long, :lat].zip(pair.map(&:to_f)).to_h
        end
      end
    end

    # http://www.movable-type.co.uk/scripts/latlong.html
    def calculate_headings
      last_heading = 0
      @coords.each_with_index do |coords, i|
        if @coords[i + 1].nil?
          coords[:head] = last_heading
        else
          coords[:head] = calculate_heading(coords, @coords[i + 1])
          last_heading = coords[:head]
        end
      end
    end

    def calculate_heading(coords, next_coords)
      lat1, lat2, long1, long2 = parse_coords(coords, next_coords)
      x, y = calculate_heading_args(lat1, lat2, long1, long2)

      Math.atan2(y, x).to_deg.normalize
    end

    def parse_coords(coords, next_coords)
      [
        coords[:lat],
        next_coords[:lat],
        coords[:long],
        next_coords[:long]
      ].map(&:to_rad)
    end

    def calculate_heading_args(lat1, lat2, long1, long2)
      y = Math.sin(long2 - long1) * Math.cos(lat2)
      x = Math.cos(lat1) * Math.sin(lat2) -
          Math.sin(lat1) * Math.cos(lat2) * Math.cos(long2 - long1)
      [x, y]
    end

    def calculate_id
      command = "Digest::#{Hyperlapse::ID_ALG}.hexdigest(@coords.to_json)"
      @id = instance_eval(command)
    end

    def error
      fail 'Invalid source(s).'
    end
  end
end
