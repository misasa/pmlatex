require 'spec_helper'

RSpec.describe Pmlatex::Update do
  let(:author) { double('remote author', id: 7, name: 'Yachi, Yusuke') }
  let(:bib) { Struct.new(:name, :author_ids, :year, :month, :volume, :pages, :global_id) do
    def save; end
    def reload; end
  end.new('Old report', [3], 2013, 3, 13, 'legacy-pages', 'bib-1') }

  before do
    write_report
    allow(MedusaRestClient::Author).to receive(:find_or_create_by_name).with('Yachi, Yusuke').and_return(author)
    allow(MedusaRestClient::Author).to receive(:find).with(7).and_return(author)
    allow(MedusaRestClient::Author).to receive(:find).with(3).and_return(double('old author', id: 3, name: 'Old, Author'))
    allow(MedusaRestClient::Record).to receive(:find).with('bib-1').and_return(bib)
    allow(bib).to receive(:save)
    allow(bib).to receive(:reload)
  end

  ['y', ''].each do |reply|
    it "updates title, authors and date after confirmation #{reply.inspect}" do
      allow(STDIN).to receive(:gets).and_return(reply + "\n")
      command(described_class).process_file('report.tex')
      expect([bib.name, bib.author_ids, bib.year, bib.month, bib.volume, bib.pages]).to eq(['Example report', [7], 2014, 4, 14, 'bib-1'])
      expect(bib).to have_received(:save).once
      expect(bib).to have_received(:reload).once
      expect(File.read('report.tex')).to eq(document)
    end
  end

  it 'updates authors when title and date already match' do
    bib.name, bib.year, bib.month = 'Example report', 2014, 4
    expect(STDIN).to receive(:gets).and_return("y\n")
    command(described_class).process_file('report.tex')
    expect(bib.author_ids).to eq([7])
    expect(bib).to have_received(:save).once
  end

  it 'leaves metadata intact when confirmation is refused' do
    allow(STDIN).to receive(:gets).and_return("n\n")
    command(described_class).process_file('report.tex')
    expect(bib.to_a).to eq(['Old report', [3], 2013, 3, 13, 'legacy-pages', 'bib-1'])
    expect(bib).not_to have_received(:save)
  end

  it 'does not prompt or save when metadata already matches, including string dates' do
    bib.name, bib.year, bib.month, bib.author_ids = 'Example report', '2014', '4', [7]
    expect(STDIN).not_to receive(:gets)
    command(described_class).process_file('report.tex')
    expect(bib).not_to have_received(:save)
  end

  it 'rejects a source without a bibliography ID before author or record lookup' do
    write_report(document(bib_id: nil))
    expect(MedusaRestClient::Author).not_to receive(:find_or_create_by_name)
    expect(MedusaRestClient::Record).not_to receive(:find)
    expect { command(described_class).process_file('report.tex') }.to raise_error(/BibliographySisyphus/)
  end

  %w[report.tex report.pdf].each do |missing|
    it "rejects missing #{missing} before any remote lookup" do
      File.delete(missing)
      expect(MedusaRestClient::Record).not_to receive(:find)
      expect(MedusaRestClient::Author).not_to receive(:find_or_create_by_name)
      expect { command(described_class).process_file('report.tex') }.to raise_error(/not found/)
    end
  end
end
