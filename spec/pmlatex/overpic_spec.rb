require 'spec_helper'

RSpec.describe Pmlatex::OverPic do
  subject(:overlay) { described_class.new }

  it 'draws the existing default clock at the specified position with two hands and an outer tick' do
    # Baseline characterization of existing formatting and angle policy, not a new scientific claim.
    expected = <<~'TEX'
      % isoclock x=10.0 y=20.0 isotope=0.0
      \color{white}\linethickness{3.2pt}
      \put(10.0,20.0){\circle{20}\rotatebox{0.0}{\line(0,1){10.0}\line(0,-1){10.0}}}
      \color{black}\linethickness{1.6pt}
      \put(10.0,20.0){\circle{20}\rotatebox{0.0}{\linethickness{1.6pt}\vector(0,1){10.0}\line(0,-1){10.0}}}
    TEX
    expect(overlay.put_isoclock(10, 20, 0)).to eq(expected + '\\qbezier(10.000,28.000)(10.000,29.000)(10.000,30.000)')
  end

  it 'converts a quarter circle between Cartesian and polar coordinates' do
    radius, angle = overlay.descartes2polar(0, 2)
    expect(radius).to eq(2.0)
    expect(angle).to be_within(1e-12).of(Math::PI / 2)
    x, y = overlay.polar2descartes(2, Math::PI / 2)
    expect(x).to be_within(1e-12).of(0)
    expect(y).to be_within(1e-12).of(2)
  end

  it 'prints an independently calculated horizontal tick with three-decimal coordinates' do
    expect(overlay.tick_for_circle(10, 20, 10, 0)).to eq('\\qbezier(19.000,20.000)(19.500,20.000)(20.000,20.000)')
  end
end
