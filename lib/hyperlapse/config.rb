module Hyperlapse
  class Config
    def initialize(id, options)
      @id = id
      @options = options
    end

    def handle
      if !@options[:app].nil?
        config_app
      elsif !@options[:api_key].nil?
        config_api_key
      elsif !@options[:where].nil?
        config_path_where
      else
        config_path
      end
    end

    private

    def config_app
      puts "App config location: #{Hyperlapse::APP_DIR}"
    end

    def config_api_key
      Hyperlapse::AppConfig.change_api_key(@options[:api_key])
    end

    def config_path
      config_manager = Hyperlapse::PathConfig.new(@id)
      config_manager.print_config
      config_manager.update_config(@options)
      config_manager.print_config
    end

    def config_path_where
      config_manager = Hyperlapse::PathConfig.new(@id)
      puts "Path config location: #{config_manager.path_dir}"
    end
  end
end
