require 'spec_helper'

describe Hyperlapse::Parser do
  before(:example) do
      allow_any_instance_of(described_class)
        .to receive(:files_ok?).and_return(true)
      allow_any_instance_of(described_class)
        .to receive(:determine_from_to)
      allow_any_instance_of(described_class)
        .to receive(:parse)

      @parser = described_class.new(['file'])
  end

  it 'operates with correct patterns to parse KML' do
    names_pattern = %r{
      <Placemark>.*\r?\n
      .*<name>(.+)<\/name>.*\r?\n
      (?:.*\r?\n)?
      .*<Point>
    }x

    coords_pattern = %r{
      <LineString>.*\r?\n
      .*\r?\n
      .*<coordinates>(.+)<\/coordinates>\r?\n
      .*<\/LineString>
    }x

    expect(Hyperlapse::Parser::NAMES_PATTERN).to eq(names_pattern)
    expect(Hyperlapse::Parser::COORDS_PATTERN).to eq(coords_pattern)
  end

  context 'handles headings correctly' do
    before(:example) do
      @coords = { lat: 42.45, long: 11.287 }
      @next_coords = { lat: 42.77, long: 10.01 }
    end

    it 'parses coordinates correctly' do
      result = @parser.send(:parse_coords, @coords, @next_coords)
      expect(result).to be_an(Array)
      expect(result).to contain_exactly(
        0.1747074581246324,
        0.19699531267259998,
        0.740892267471593,
        0.7464773210779748
      )
    end

    it 'calculates partial arguments correctly' do
      lat1 = 0.1747074581246324
      lat2 = 0.19699531267259998
      long1 = 0.740892267471593
      long2 = 0.7464773210779748

      result = @parser.send(:calculate_heading_args,
                            lat1, lat2, long1, long2)

      expect(result).to be_an(Array)
      expect(result.length).to eq(2)
      expect(result).to contain_exactly(
        0.005477005124844477, 0.0222886678805716
      )
    end

    it 'calculates headings correctly' do
      result = @parser.send(:calculate_heading, @coords, @next_coords)
      expect(result).to eq(289.23429817453683)
    end
  end

  context 'calculates IDs correctly' do
    before(:example) do
      coords = double(to_json: 'test data')
      @coords_bk = @parser.instance_variable_get('@coords')
      @parser.instance_variable_set('@coords', coords)
    end

    after(:example) do
      @parser.instance_variable_set('@coords', @coords_bk)
    end

    it 'using MD5' do
      stub_const('Hyperlapse::ID_ALG', 'MD5')
      id = @parser.send(:calculate_id)
      expect(id.length).to eq(32)
      expect(id).to eq('eb733a00c0c9d336e65691a37ab54293')
    end

    it 'using SHA1' do
      stub_const('Hyperlapse::ID_ALG', 'SHA1')
      id = @parser.send(:calculate_id)
      expect(id.length).to eq(40)
      expect(id).to eq('f48dd853820860816c75d54d0f584dc863327a7c')
    end

    it 'using SHA256' do
      stub_const('Hyperlapse::ID_ALG', 'SHA256')
      id = @parser.send(:calculate_id)
      expect(id.length).to eq(64)
      expect(id).to eq('916f0027a575074ce72a331777c3478d6513f786a591bd892d'\
                       'a1a577bf2335f9')
    end

    it 'using SHA384' do
      stub_const('Hyperlapse::ID_ALG', 'SHA384')
      id = @parser.send(:calculate_id)
      expect(id.length).to eq(96)
      expect(id).to eq('29901176dc824ac3fd22227677499f02e4e69477ccc501593c'\
                       'c3dc8c6bfef73a08dfdf4a801723c0479b74d6f1abc372')
    end

    it 'using SHA512' do
      stub_const('Hyperlapse::ID_ALG', 'SHA512')
      id = @parser.send(:calculate_id)
      expect(id.length).to eq(128)
      expect(id).to eq('0e1e21ecf105ec853d24d728867ad70613c21663a4693074b2'\
                       'a3619c1bd39d66b588c33723bb466c72424e80e3ca63c24907'\
                       '8ab347bab9428500e7ee43059d0d')
    end
  end
end
