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
        @config[:limit] = options[:limit].to_i unless options[:limit].nil?
        @config[:fps] = options[:fps].to_i unless options[:fps].nil?
        @config[:step] = (@config[:waypoints].length - 1) /
          (@config[:limit] - 1).to_f
        @config[:step] = [@config[:step], 1.0].max
      end

      save_config
    end

    private

    def create_config(path)
      path[:fps] = Hyperlapse::FPS
      path[:limit] = Hyperlapse::API_LIMIT
      path[:step] = (path[:waypoints].length - 1) / (path[:limit] - 1).to_f
      path[:step] = [path[:step], 1.0].max

      app_dir = Hyperlapse::APP_DIR
      path_dir = File.join(app_dir, path[:id])
      return if Dir.exist?(path_dir)

      Dir.mkdir(path_dir)
      Dir.mkdir(File.join(path_dir, 'pics'))
      Dir.mkdir(File.join(path_dir, 'maps'))
      Dir.mkdir(File.join(path_dir, 'empty'))
      Dir.mkdir(File.join(path_dir, 'output'))

      workplace_dir = File.join(path_dir, 'workplace')
      Dir.mkdir(workplace_dir)
      Dir.mkdir(File.join(workplace_dir, 'pics'))
      Dir.mkdir(File.join(workplace_dir, 'maps'))
      Dir.mkdir(File.join(workplace_dir, 'composite'))

      File.open(File.join(path_dir, 'config.json'), 'w+') do |file|
        file.write(JSON.pretty_generate(path))
      end
    end

    def load_config(id)
      if Dir.entries(Hyperlapse::APP_DIR).length == 2
        no_paths_available
      elsif id.nil?
        load_config_interactive
      else
        @id = id
        config_file = File.join(Hyperlapse::APP_DIR, @id, 'config.json')
        @config = JSON.parse(File.read(config_file), symbolize_names: true)
      end
    end

    def load_config_interactive
      ids = get_available_paths
      print_available_paths(ids)
      response = ask_user_which_path(ids)

      fail if response == 'q' # FIXME
      load_config(ids[response.to_i])
    end

    def get_available_paths
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

      while !(responses.include?(response)) do
        print "Which one to use (#{0}-#{path_ids.length - 1} or 'q')? "
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

    def update_config_interactive
      frames_all = @config[:waypoints].length
      frames_used = [@config[:limit], frames_all].min

      if frames_all > Hyperlapse::API_LIMIT
        download_days = (frames_all.to_f / Hyperlapse::API_LIMIT).ceil
        message_p1 = <<~END
          Downloading all #{frames_all} frames (covering every available
          waypoint) would take #{download_days} days
        END
        message_p2 = <<~END
          (due to daily Google API limit of #{Hyperlapse::API_LIMIT}
          requests).
        END

        puts message_p1.gsub("\n", ' ')
        puts message_p2.gsub("\n", ' ')

        response = nil
        while !(['y', 'n'].include?(response)) do
          print 'Do you want the hyperlapse today? (y/n) '
          response = STDIN.gets.chomp
        end

        if response == 'y'
          @config[:limit] = Hyperlapse::API_LIMIT
        else
          @config[:limit] = frames_used = frames_all
        end
      end

      frames_used = [@config[:limit], frames_all].min
      frame_rates = [5, 10, 15, 20, 24, 25, 30, 48, 60, 120]

      puts
      frame_rates.each_with_index do |fps, i|
        video_length = format_video_length(frames_used / fps.to_f)
        message = <<~END
          (#{i}): #{fps} fps, #{frames_used} frames,
          resulting video length: #{video_length}
        END
        puts message.gsub("\n", ' ')
      end
      puts

      response = nil
      while !((0..9).to_a.map(&:to_s).include?(response)) do
        print 'Choose desired configuration (0-9): '
        response = STDIN.gets.chomp
      end

      @config[:fps] = frame_rates[response.to_i]
      @config[:step] = (frames_all - 1) / (@config[:limit] - 1).to_f
      @config[:step] = [@config[:step], 1.0].max
    end

    def save_config
      File.open(File.join(@path_dir, 'config.json'), 'w+') do |file|
        file.write(JSON.pretty_generate(@config))
      end
    end

    def no_paths_available
      fail 'No paths available.' # TODO: Test
    end
  end
end
