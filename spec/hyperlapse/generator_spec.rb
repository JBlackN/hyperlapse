require 'spec_helper'

describe Hyperlapse::Generator do
  before(:example) do
    @config_manager = double(
      config: {},
      pics_dir: '',
      maps_dir: '',
      empty_dir: '',
      output_dir: '',
      pics_scale_dir: '',
      maps_scale_dir: '',
      composite_dir: ''
    )
  end

  it 'is able to get files in given directory' do
    generator = described_class.new(@config_manager)
    files = generator.send(:get_files, Hyperlapse::APP_DIR)

    expect(files).to be_a(Array)
    expect(files).to contain_exactly('config.json')
  end
end
