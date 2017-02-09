require 'spec_helper'

describe Hyperlapse::PathConfig do
  before(:example) do
    allow_any_instance_of(described_class)
      .to receive(:load_config)
    allow_any_instance_of(described_class)
      .to receive(:load_dirs)
    @config_manager = described_class.new(nil, nil)
  end

  it 'configures path properly' do
    stub_const('Hyperlapse::FPS', 25)
    stub_const('Hyperlapse::API_LIMIT', 25_000)

    path = { waypoints: (0..54_321).to_a }
    result = @config_manager.send(:configure_path, path)
    expect(result[:waypoints].length).to eq(54_322)
    expect(result).to match(
      waypoints: Array,
      fps: 25,
      limit: 25_000,
      step: 2.172926917076683
    )
  end

  context 'prints messages correctly' do
    before(:example) do
      config = {
        from: 'A',
        to: 'B'
      }

      @config_bk = @config_manager.instance_variable_get('@config')
      @config_manager.instance_variable_set('@config', config)
    end

    after(:example) do
      @config_manager.instance_variable_set('@config', @config_bk)
    end

    it 'configuration header' do
      header = "Configuration: Path from 'A' to 'B'\n"

      allow(STDOUT).to receive(:puts).with(no_args)
      allow(STDOUT).to receive(:puts).with(header)
      allow(@config_manager).to receive(:print_separator).once
      allow(STDOUT).to receive(:puts).with(no_args)

      @config_manager.send(:print_header)
    end

    # it 'configuration' do
    # end

    # it 'daily limit' do
    # end

    # it 'FPS options' do
    # end
  end
end
