require 'spec_helper'

RSpec.describe Pmlatex::TexLog do
  it 'extracts and deduplicates paths in first-seen order from synthetic log text' do
    source = '(./report.tex (./mount/figure0.tex) (./mount/origin.tex) (./report.tex)'
    expect(described_class.scan_tex_path(source)).to eq(%w[./report.tex ./mount/figure0.tex ./mount/origin.tex])
  end

  it 'reads the historical log fixture using the real file parser' do
    paths = described_class.from_file(fixture('no_such_file.log')).include_files
    expect(paths).to include('./report.tex', './mount/figure0.tex', './mount/origin.tex')
    expect(paths).to eq(paths.uniq)
  end

  it 'returns no paths for empty text' do
    expect(described_class.scan_tex_path('')).to eq([])
  end

  it 'retains the nil input boundary' do
    expect(described_class.scan_tex_path(nil)).to be_nil
  end

  it 'fails for a missing log instead of treating it as an empty log' do
    expect { described_class.from_file('absent.log') }.to raise_error(Errno::ENOENT)
  end
end
