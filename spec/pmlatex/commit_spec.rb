require 'spec_helper'

RSpec.describe Pmlatex::Commit do
  let(:attachment) { double('remote attachment', data_file_name: 'report.pdf', global_id: 'file-1') }
  let(:attachments) { [] }
  let(:bib) { double('remote bib', attachment_files: attachments, name: 'Example report', global_id: 'bib-1') }

  before do
    write_report
    allow(MedusaRestClient::Record).to receive(:find).with('bib-1').and_return(bib)
    allow(bib).to receive(:upload_file)
  end

  it 'uploads the PDF belonging to the parsed bibliography ID' do
    command(described_class).process_file('report.tex')
    expect(bib).to have_received(:upload_file).with(file: './report.pdf').once
  end

  {'n' => [false, false], 'append' => [false, true], '' => [true, true], 'y' => [true, true]}.each do |reply, (destroy, upload)|
    context "with reply #{reply.inspect}" do
      let(:attachments) { [attachment] }
      it 'honors the replacement decision before uploading' do
        allow(STDIN).to receive(:gets).and_return(reply + "\n")
        expect(attachment).to receive(:destroy).exactly(destroy ? 1 : 0).times
        command(described_class).process_file('report.tex')
        expect(bib).to have_received(:upload_file).exactly(upload ? 1 : 0).times
      end
    end
  end

  it 'does not prompt or delete an attachment with a different filename' do
    attachments << double('other attachment', data_file_name: 'other.pdf')
    expect(STDIN).not_to receive(:gets)
    command(described_class).process_file('report.tex')
    expect(bib).to have_received(:upload_file).once
  end

  it 'rejects a source without a bibliography ID before a remote lookup' do
    write_report(document(bib_id: nil))
    expect(MedusaRestClient::Record).not_to receive(:find)
    expect { command(described_class).process_file('report.tex') }.to raise_error(/BibliographySisyphus/)
  end

  %w[report.tex report.pdf].each do |missing|
    it "rejects missing #{missing} before a remote lookup" do
      File.delete(missing)
      expect(MedusaRestClient::Record).not_to receive(:find)
      expect { command(described_class).process_file('report.tex') }.to raise_error(/not found/)
    end
  end
end
