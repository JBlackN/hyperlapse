require 'spec_helper'

describe Hyperlapse::AppConfig do
  context 'handles config properly' do
    it 'loads config' do
      daily_limit = Hyperlapse::AppConfig.load('downloader', 'daily_limit')
      resolution = Hyperlapse::AppConfig.load('generator', 'resolution')
      map_scale = Hyperlapse::AppConfig.load('generator', 'map_scale')
      id_alg = Hyperlapse::AppConfig.load('parser', 'id_alg')

      expect(daily_limit).to be_a(Integer)
      expect(resolution).to be_a(Hash)
      expect(resolution).to have_key('w')
      expect(resolution).to have_key('h')
      expect(resolution['w']).to be_a(Integer)
      expect(resolution['h']).to be_a(Integer)
      expect(map_scale).to be_a(Float)
      expect(id_alg).to be_a(String)
    end

    it 'sets constants' do
      id_alg = Hyperlapse::AppConfig.load('parser', 'id_alg')
      api_host = Hyperlapse::AppConfig.load('downloader', 'host')
      api_metadata_path =
        Hyperlapse::AppConfig.load('downloader', 'metadata_path')
      api_pics_path = Hyperlapse::AppConfig.load('downloader', 'pics_path')
      api_maps_path = Hyperlapse::AppConfig.load('downloader', 'maps_path')
      api_key = Hyperlapse::AppConfig.load('downloader', 'key')
      api_limit = Hyperlapse::AppConfig.load('downloader', 'daily_limit')
      fov = Hyperlapse::AppConfig.load('downloader', 'fov')
      width = Hyperlapse::AppConfig.load('generator', 'resolution')['w']
      height = Hyperlapse::AppConfig.load('generator', 'resolution')['h']
      fps = Hyperlapse::AppConfig.load('generator', 'fps')
      map_pos = Hyperlapse::AppConfig.load('generator', 'map_position')
      map_scale = Hyperlapse::AppConfig.load('generator', 'map_scale')

      expect(Hyperlapse::APP_DIR).to eq(File.join(Dir.home, '.hyperlapse'))
      expect(Hyperlapse::ID_ALG).to eq(id_alg)
      expect(Hyperlapse::API_HOST).to eq(api_host)
      expect(Hyperlapse::API_METADATA_PATH).to eq(api_metadata_path)
      expect(Hyperlapse::API_PICS_PATH).to eq(api_pics_path)
      expect(Hyperlapse::API_MAPS_PATH).to eq(api_maps_path)
      expect(Hyperlapse::API_KEY).to eq(api_key)
      expect(Hyperlapse::API_LIMIT).to eq(api_limit)
      expect(Hyperlapse::FOV).to eq(fov)
      expect(Hyperlapse::WIDTH).to eq(width)
      expect(Hyperlapse::HEIGHT).to eq(height)
      expect(Hyperlapse::FPS).to eq(fps)
      expect(Hyperlapse::MAP_POS).to eq(map_pos)
      expect(Hyperlapse::MAP_SCALE).to eq(map_scale)
    end
  end
end
