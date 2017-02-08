require 'json'

module Hyperlapse
  module AppConfig
    module_function

    def create
      create_app_dir
      create_config
      puts 'Don\'t forget to set your Google API key (see README).'
    end

    def check
      config_file = File.join(Hyperlapse::APP_DIR, 'config.json')

      app_dir_exists = Dir.exist?(Hyperlapse::APP_DIR)
      config_file_exists = File.file?(config_file)

      create unless app_dir_exists && config_file_exists
    end

    def check_api_key
      config_file = File.join(Hyperlapse::APP_DIR, 'config.json')
      app_config = JSON.parse(File.read(config_file))
      !app_config['downloader']['key'].empty?
    end

    def set_api_key(key)
      config_file = File.join(Hyperlapse::APP_DIR, 'config.json')
      app_config = JSON.parse(File.read(config_file))
      app_config['downloader']['key'] = key

      save(app_config, config_file)
    end

    def load(category, key)
      config_file = File.join(Hyperlapse::APP_DIR, 'config.json')
      app_config = JSON.parse(File.read(config_file))
      app_config[category][key]
    end

    private_class_method

    def create_app_dir
      Dir.mkdir(Hyperlapse::APP_DIR) unless Dir.exist?(Hyperlapse::APP_DIR)
    end

    def create_config
      config_file = File.join(Hyperlapse::APP_DIR, 'config.json')

      app_config = {
        downloader: default_config_downloader,
        generator: default_config_generator,
        parser: default_config_parser
      }

      save(app_config, config_file) unless File.file?(config_file)
    end

    def default_config_downloader
      {
        host: 'maps.googleapis.com',
        metadata_path: '/maps/api/streetview/metadata',
        pics_path: '/maps/api/streetview',
        maps_path: '/maps/api/staticmap',
        key: '',
        daily_limit: 25000,
        fov: 110
      }
    end

    def default_config_generator
      {
        resolution: { w: 1920, h: 1080 },
        fps: 25,
        map_position: 'NorthEast',
        map_scale: 0.333333
      }
    end

    def default_config_parser
      { id_alg: 'SHA512' }
    end

    def save(app_config, config_file)
      File.open(config_file, 'w') do |file|
        file.write(JSON.pretty_generate(app_config))
      end
    end
  end

  APP_DIR = File.join(Dir.home, '.hyperlapse')

  Hyperlapse::AppConfig.check

  ID_ALG = Hyperlapse::AppConfig.load('parser', 'id_alg')

  API_HOST = Hyperlapse::AppConfig.load('downloader', 'host')
  API_METADATA_PATH =
    Hyperlapse::AppConfig.load('downloader', 'metadata_path')
  API_PICS_PATH = Hyperlapse::AppConfig.load('downloader', 'pics_path')
  API_MAPS_PATH = Hyperlapse::AppConfig.load('downloader', 'maps_path')
  API_KEY = Hyperlapse::AppConfig.load('downloader', 'key')
  API_LIMIT = Hyperlapse::AppConfig.load('downloader', 'daily_limit')

  FOV = Hyperlapse::AppConfig.load('downloader', 'fov')
  WIDTH = Hyperlapse::AppConfig.load('generator', 'resolution')['w']
  HEIGHT = Hyperlapse::AppConfig.load('generator', 'resolution')['h']
  FPS = Hyperlapse::AppConfig.load('generator', 'fps')
  MAP_POS = Hyperlapse::AppConfig.load('generator', 'map_position')
  MAP_SCALE = Hyperlapse::AppConfig.load('generator', 'map_scale')
end
