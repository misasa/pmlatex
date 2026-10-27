require 'spec_helper'

RSpec.describe Pmlatex::Add do
  let(:author) { double('remote author', id: 7) }
  let(:bib) do
    # State belongs to the remote boundary; actual parsing, backup and save stay real.
    Struct.new(:name, :entry_type, :author_ids, :journal, :year, :volume, :month, :pages, :global_id) do
      def save; end
      def reload; end
    end.new.tap do |record|
      record.global_id = 'created-1'
    end
  end

  before do
    allow(MedusaRestClient::Author).to receive(:find_or_create_by_name).with('Yachi, Yusuke').and_return(author)
    allow(MedusaRestClient::Bib).to receive(:new).and_return(bib)
    allow(bib).to receive(:save)
    allow(bib).to receive(:reload)
  end

  it 'creates metadata, backs up the original source, and embeds the server ID' do
    original = document(bib_id: nil)
    write_report(original)
    expect(Pmlatex::Scan).not_to receive(:process_file)
    expect { command(described_class).process_file('report.tex') }.to output(/Hint/).to_stdout
    expect([bib.name, bib.entry_type, bib.author_ids, bib.journal, bib.year, bib.volume, bib.month, bib.pages]).to eq(
      ['Example report', 'article', [7], 'DREAM Digital Document', 2014, 14, 4, 'created-1'])
    expect(bib).to have_received(:save).twice
    expect(bib).to have_received(:reload).twice
    expect(File.read('report.tex.backup')).to eq(original)
    expected = original.sub("\\maketitle\n", "\\maketitle\n\\BibliographySisyphus{created-1} % take this line out on a new report\n")
    expect(File.read('report.tex')).to eq(expected)
  end

  it 'refuses an already paired document before creating a remote record' do
    write_report
    expect(MedusaRestClient::Bib).not_to receive(:new)
    expect { command(described_class).process_file('report.tex') }.to raise_error(/already paired/)
    expect(File.exist?('report.tex.backup')).to be(false)
  end

  %w[report.tex report.pdf].each do |missing|
    it "rejects missing #{missing} before remote author creation" do
      write_report(document(bib_id: nil))
      File.delete(missing)
      expect(MedusaRestClient::Author).not_to receive(:find_or_create_by_name)
      expect { command(described_class).process_file('report.tex') }.to raise_error(/not found/)
    end
  end
end
