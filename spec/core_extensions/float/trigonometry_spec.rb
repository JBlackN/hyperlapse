require 'spec_helper'

RSpec.describe CoreExtensions::Float::Trigonometry do
  it 'converts degrees to radians' do
    expect(180.0.to_rad).to eq(Math::PI)
  end

  it 'converts radians to degrees' do
    expect(Math::PI.to_deg).to eq(180.0)
  end

  it 'normalizes values from (-180..180) to (0..360)' do
    expect(-60.0.normalize).to eq(300.0)
  end
end
