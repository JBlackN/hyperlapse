# frozen_string_literal: false
module Hyperlapse
  class PathConfig
    def initialize(id, path = nil)
      if path.nil?
        load_config(id)
        load_dirs
      else
        create_config(path)
      end
    end

    attr_reader :config, :path_dir
    attr_reader :pics_dir, :maps_dir, :empty_dir, :output_dir
    attr_reader :workplace_dir
    attr_reader :pics_scale_dir, :maps_scale_dir, :composite_dir

    def print_config
      print_header
      print_content
    end

    def update_config(options)
      if options.empty?
        update_config_interactive
      else
        update_config_noninteractive(options)
      end

      save_config
    end

    private

    # Create

    def create_config(path)
      path = configure_path(path)
      path_dir = create_path_dir(path)
      create_path_dir_tree(path_dir)

      File.open(File.join(path_dir, 'config.json'), 'w+') do |file|
        file.write(JSON.pretty_generate(path))
      end
    end

    def configure_path(path)
      path[:fps] = Hyperlapse::FPS
      path[:limit] = Hyperlapse::API_LIMIT
      path[:step] = (path[:waypoints].length - 1) / (path[:limit] - 1).to_f
      path[:step] = [path[:step], 1.0].max
    end

    def create_path_dir(path)
      path_dir = File.join(Hyperlapse::APP_DIR, path[:id])
      return if Dir.exist?(path_dir)
      Dir.mkdir(path_dir)
      path_dir
    end

    def create_path_dir_tree(path_dir)
      Dir.mkdir(File.join(path_dir, 'pics'))
      Dir.mkdir(File.join(path_dir, 'maps'))
      Dir.mkdir(File.join(path_dir, 'empty'))
      Dir.mkdir(File.join(path_dir, 'output'))

      create_workplace_dir_tree(File.join(path_dir, 'workplace'))
    end

    def create_workplace_dir_tree(workplace_dir)
      Dir.mkdir(workplace_dir)
      Dir.mkdir(File.join(workplace_dir, 'pics'))
      Dir.mkdir(File.join(workplace_dir, 'maps'))
      Dir.mkdir(File.join(workplace_dir, 'composite'))
    end

    # Load

    def load_config(id)
      if Dir.entries(Hyperlapse::APP_DIR).length == 2
        no_paths_available
      elsif id.nil?
        load_config_interactive
      else
        load_config_noninteractive(id)
      end
    end

    def load_config_interactive
      ids = available_paths
      print_available_paths(ids)
      response = ask_user_which_path(ids)

      fail if response == 'q' # FIXME
      load_config(ids[response.to_i])
    end

    def load_config_noninteractive(id)
      @id = id
      config_file = File.join(Hyperlapse::APP_DIR, @id, 'config.json')
      @config = JSON.parse(File.read(config_file), symbolize_names: true)
    end

    def available_paths
      Dir.entries(Hyperlapse::APP_DIR).select do |entry|
        entry_path = File.join(Hyperlapse::APP_DIR, entry)
        File.directory?(entry_path) && !(entry == '.' || entry == '..')
      end
    end

    def print_available_paths(path_ids)
      path_ids.each_with_index do |id, index|
        config_file = File.join(Hyperlapse::APP_DIR, id, 'config.json')
        config = JSON.parse(File.read(config_file), symbolize_names: true)
        puts "(#{index}): From '#{config[:from]}' to '#{config[:to]}'."
      end
    end

    def ask_user_which_path(path_ids)
      responses = ['q'] + (0...path_ids.length).to_a.map(&:to_s)
      response = nil

      until responses.include?(response)
        print "Which one to use (0-#{path_ids.length - 1} or 'q')? "
        response = STDIN.gets.chomp
      end

      exit if response == 'q'
      response
    end

    def load_dirs
      @path_dir = File.join(Hyperlapse::APP_DIR, @id)
      @maps_dir = File.join(@path_dir, 'maps')
      @pics_dir = File.join(@path_dir, 'pics')
      @empty_dir = File.join(@path_dir, 'empty')
      @output_dir = File.join(@path_dir, 'output')
      @workplace_dir = File.join(@path_dir, 'workplace')
      @pics_scale_dir = File.join(@workplace_dir, 'pics')
      @maps_scale_dir = File.join(@workplace_dir, 'maps')
      @composite_dir = File.join(@workplace_dir, 'composite')
    end

    # Print

    def print_header
      header = <<~END
        Configuration: Path from '#{@config[:from]}' to '#{@config[:to]}'
      END

      puts
      puts header
      header.chomp.length.times { print '=' }
      puts
    end

    def print_content
      config = format_config

      puts
      puts "* Frames available (waypoints): #{config[:frames_available]}"
      puts "* Frames used: #{config[:frames_used]} (#{config[:fu_perc]}%)"
      puts "* Frames per second: #{config[:fps]}"
      puts "* Resulting video length: #{config[:video_length]}"
      puts "* Google API daily limit: #{Hyperlapse::API_LIMIT}"
      puts "* Days needed for download: #{config[:download_days]}"
      puts
    end

    def format_config
      frames_all = @config[:waypoints].length
      frames_used = [@config[:limit], frames_all].min

      {
        fps: @config[:fps],
        frames_available: frames_all,
        frames_used: frames_used,
        fu_perc: ((frames_used / frames_all.to_f) * 100).round(2),
        download_days: (frames_used.to_f / Hyperlapse::API_LIMIT).ceil,
        video_length: format_video_length(frames_used / @config[:fps].to_f)
      }
    end

    def format_video_length(video_length)
      if video_length > 60
        (video_length / 60).round(2).to_s + ' min'
      else
        video_length.round(2).to_s + ' s'
      end
    end

    # Update

    def update_config_interactive
      frames_all = @config[:waypoints].length
      update_limit_i(frames_all) if frames_all > Hyperlapse::API_LIMIT

      frames_used = [@config[:limit], frames_all].min
      update_fps_i(frames_all, frames_used)
    end

    def update_limit_i(frames_all)
      download_days = (frames_all.to_f / Hyperlapse::API_LIMIT).ceil
      print_limit_message(frames_all, download_days)
      response = ask_user_if_today

      @config[:limit] = response == 'y' ? Hyperlapse::API_LIMIT : frames_all
    end

    def print_limit_message(frames_all, download_days)
      puts <<~END.tr("\n", ' ')
        Downloading all #{frames_all} frames (covering every available
        waypoint) would take #{download_days} days
      END

      puts <<~END.tr("\n", ' ')
        (due to daily Google API limit of #{Hyperlapse::API_LIMIT}
        requests).
      END
    end

    def ask_user_if_today
      response = nil
      until %w(y n).include?(response)
        print 'Do you want the hyperlapse today? (y/n) '
        response = STDIN.gets.chomp
      end

      response
    end

    def update_fps_i(frames_all, frames_used)
      frame_rates = [1, 5, 10, 15, 20, 24, 25, 30, 48, 60, 120]
      print_fps_options(frame_rates, frames_used)
      response = ask_user_which_fps(frame_rates)

      @config[:fps] = frame_rates[response.to_i]
      update_step(frames_all)
    end

    def print_fps_options(frame_rates, frames_used)
      puts
      frame_rates.each_with_index do |fps, i|
        video_length = format_video_length(frames_used / fps.to_f)
        puts <<~END.tr("\n", ' ')
          (#{i}): #{fps} fps, #{frames_used} frames,
          resulting video length: #{video_length}
        END
      end
      puts
    end

    def ask_user_which_fps(frame_rates)
      response = nil
      until (0...frame_rates.length).to_a.map(&:to_s).include?(response)
        print "Choose desired configuration (0-#{frame_rates.length - 1}): "
        response = STDIN.gets.chomp
      end

      response
    end

    def update_config_noninteractive(options)
      @config[:limit] = options[:limit].to_i unless options[:limit].nil?
      @config[:fps] = options[:fps].to_i unless options[:fps].nil?
      update_step(@config[:waypoints].length)
    end

    def update_step(frames_all)
      @config[:step] = (frames_all - 1) / (@config[:limit] - 1).to_f
      @config[:step] = [@config[:step], 1.0].max
    end

    def save_config
      File.open(File.join(@path_dir, 'config.json'), 'w+') do |file|
        file.write(JSON.pretty_generate(@config))
      end
    end

    # Errors

    def no_paths_available
      fail 'No paths available.' # TODO: Test
    end
  end
end
