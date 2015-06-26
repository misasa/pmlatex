require 'spec_helper'
require 'medusa_rest_client'

module Pmlatex
	describe Commit do
		before(:each) do
			# FakeWeb.allow_net_connect = true
			# setup_medusa
			setup_empty_dir('tmp')
		end
		describe "#process_file" do
			subject { cui.process_file(tex_path) }
			let(:tex_path){ 'tmp/template.tex' }
			let(:pdf_path){ 'tmp/template.pdf' }
			let(:cui) { Pmlatex::Commit.new(myout, [tex_path]) }
			let(:bib) { double("bib", :attachment_files => attachment_files) }
			let(:tex) { double("tex", :bib_id => "0000-001")}
			let(:attachment_files){ [] }
			before(:each) do
				setup_file(tex_path)
				setup_file(pdf_path)

				allow(Tex).to receive(:from_file).and_return(tex)
				allow(MedusaRestClient::Record).to receive(:find).and_return(bib)
				allow(bib).to receive(:upload_file)
			end
			it {
				expect(Tex).to receive(:from_file).with(tex_path, false).and_return(tex)
				subject
			}

			it {
				expect(MedusaRestClient::Record).to receive(:find).with(tex.bib_id).and_return(bib)
				subject
			}

			it {
				expect(bib).to receive(:upload_file).with({:file => pdf_path})
				subject
			}

		end

	end
end