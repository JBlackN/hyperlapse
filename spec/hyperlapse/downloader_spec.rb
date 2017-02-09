require 'spec_helper'

describe Hyperlapse::Downloader do
  context 'generates proper Google API URLs/paths' do
    before(:example) do
      @waypoint = { lat: 50.166, long: 17.453, head: 129.776 }
      @config_manager = double(
        config: {},
        pics_dir: '',
        maps_dir: '',
        empty_dir: ''
      )
      @options = { optimize: false }

      stub_const('Hyperlapse::API_HOST', 'maps.googleapis.com')
      stub_const('Hyperlapse::API_METADATA_PATH',
                 '/maps/api/streetview/metadata')
      stub_const('Hyperlapse::API_PICS_PATH', '/maps/api/streetview')
      stub_const('Hyperlapse::API_MAPS_PATH', '/maps/api/staticmap')
      stub_const('Hyperlapse::API_KEY', 'API_KEY')
      stub_const('Hyperlapse::FOV', 110)
    end

    it 'generates proper Street View metadata path' do
      downloader = described_class.new(@config_manager, @options)
      path = downloader.send(:street_view_metadata_path, @waypoint)
      expected = '/maps/api/streetview/metadata?size=640x360&location='\
                 '50.166,17.453&fov=110&heading=129.776&pitch=0&key=API_KEY'

      expect(path).to eq(expected)
    end

    it 'generates proper Street View URL' do
      downloader = described_class.new(@config_manager, @options)
      url = downloader.send(:street_view_uri, @waypoint)
      expected = 'http://maps.googleapis.com/maps/api/streetview?size='\
                 '640x360&location=50.166,17.453&fov=110&heading=129.776&'\
                 'pitch=0&key=API_KEY'

      expect(url).to eq(expected)
    end

    it 'generates proper Static Maps URL' do
      downloader = described_class.new(@config_manager, @options)
      url = downloader.send(:map_uri, @waypoint)
      expected = 'http://maps.googleapis.com/maps/api/staticmap?center='\
                 '50.166,17.453&zoom=9&size=640x360&maptype=roadmap'\
                 '&markers=color:red%7Clabel:R%7C50.166,17.453&key=API_KEY'

      expect(url).to eq(expected)
    end
  end
end
