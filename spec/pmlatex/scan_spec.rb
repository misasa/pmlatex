require 'spec_helper'

RSpec.describe Pmlatex::Scan do
  let(:bib) { double('remote bib', relatives: []) }
  let(:stone_relatives) { [] }
  let(:stone) { double('remote stone', relatives: stone_relatives) }

  before do
    allow(MedusaRestClient::Record).to receive(:find).with('bib-1').and_return(bib)
    allow(MedusaRestClient::Record).to receive(:find).with('stone-1').and_return(stone)
  end

  it 'recurses into actual included files and accumulates child IDs before parent IDs' do
    File.write('child.tex', "\n\\cite{stone-1}\n")
    tex = Pmlatex::Tex.new("\\input{child}\n\\cite{bib-1}\n")
    tex.parse
    expect(described_class.rcheck_cite([], tex)).to eq(%w[stone-1 bib-1])
  end

  it 'warns about a missing included file but still checks parent citations' do
    tex = Pmlatex::Tex.new("\\input{absent}\n\\cite{stone-1}\n")
    tex.parse
    ids = nil
    expect { ids = described_class.rcheck_cite([], tex) }.to output(/Warning/).to_stdout
    expect(ids).to eq(['stone-1'])
  end

  it 'omits failed remote lookups and retains successful citations' do
    allow(MedusaRestClient::Record).to receive(:find).with('missing').and_raise(StandardError, 'not found')
    tex = Pmlatex::Tex.new('\\cite{missing} \\citep{stone-1}')
    tex.parse
    expect(described_class.check_cite(tex)).to eq(['stone-1'])
  end

  it 'links unique citations, preserves the input and writes the complete ss command file' do
    source = document + "\\cite{stone-1} \\cite{stone-1}\n"
    write_report(source)
    described_class.process_file('report.tex')
    expect(stone_relatives).to eq([bib])
    expect(File.read('report.ss')).to eq("bib-1\nparent\nstone-1\nchildren -y\n")
    expect(File.read('report.tex')).to eq(source)
  end

  it 'includes citations discovered only through the TeX log' do
    write_report
    File.write('report.log', '(./extra.tex)')
    File.write('extra.tex', '\\refdream{stone-1}')
    described_class.process_file('report.tex')
    expect(stone_relatives).to eq([bib])
    expect(File.read('report.ss')).to eq("bib-1\nparent\nstone-1\nchildren -y\n")
  end

  it 'does not relink existing relatives but still exports their IDs' do
    write_report(document + '\\cite{stone-1}')
    allow(bib).to receive(:relatives).and_return([double('linked relative', global_id: 'stone-1')])
    described_class.process_file('report.tex')
    expect(stone_relatives).to be_empty
    expect(File.read('report.ss')).to include("stone-1\n")
  end

  it 'does not write an ss file when no citations resolve' do
    write_report
    described_class.process_file('report.tex')
    expect(File.exist?('report.ss')).to be(false)
  end

  it 'reports a missing remote bibliography and does not write an ss file' do
    write_report
    allow(MedusaRestClient::Record).to receive(:find).with('bib-1').and_raise(StandardError, 'not found')
    expect { described_class.process_file('report.tex') }.to raise_error(/not found on database/)
    expect(File.exist?('report.ss')).to be(false)
  end

  it 'rejects a missing bibliography ID before a remote lookup' do
    write_report(document(bib_id: nil))
    expect(MedusaRestClient::Record).not_to receive(:find)
    expect { described_class.process_file('report.tex') }.to raise_error(/BibliographySisyphus/)
  end

  %w[report.tex report.pdf].each do |missing|
    it "rejects missing #{missing} before a remote lookup" do
      write_report
      File.delete(missing)
      expect(MedusaRestClient::Record).not_to receive(:find)
      expect { described_class.process_file('report.tex') }.to raise_error(/not found/)
    end
  end
end
