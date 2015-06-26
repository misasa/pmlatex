require 'spec_helper'
require 'medusa_rest_client'
module Pmlatex
	describe Add do
#		let(:output) { double('output').as_null_object }
		before(:each) do
#			setup_medusa
			#@tmp_path = File.expand_path('../../../tmp',__FILE__)
#			FakeWeb.allow_net_connect = true
#			setup_medusa
			setup_empty_dir('tmp')
		end

		describe "#process_file" do
			subject { cui.process_file(tex_path) }
			let(:cui) { Pmlatex::Add.new(myout, args) }
			let(:tex_path) { 'tmp/template.tex' }
			let(:pdf_path) { 'tmp/template.pdf'}
			let(:args){ [tex_path]}
			let(:tex) { double("tex", :author_fullnames => author_names).as_null_object }
			let(:author) { double("author").as_null_object }
			let(:author_names) { ['Yusuke Yachi'] }
			let(:bib){ double("bib", :global_id => "0000-001").as_null_object}
			before do
				setup_file(tex_path)
				setup_file(pdf_path)
				#bib = double("bib", :id => 2).as_null_object
				#tex = double("tex")
				allow(tex).to receive(:bib_id).and_return(nil)
				allow(Tex).to receive(:from_file).and_return(tex)
				allow(MedusaRestClient::Author).to receive(:find_or_create_by_name).and_return(author)
				allow(MedusaRestClient::Bib).to receive(:new).and_return(bib)
				allow(Scan).to receive(:process_file)
			end

			it {
				expect(Tex).to receive(:from_file).with(tex_path, false).and_return(tex)
				subject
			}

			it {
				expect(MedusaRestClient::Author).to receive(:find_or_create_by_name).and_return(author)
				subject
			}
			it {
			    expect(tex).to receive(:insert_bib_line).with("\\BibliographySisyphus{0000-001} % take this line out on new report")
			    subject
			}
			it {
	    		expect(tex).to receive(:save).with(tex_path)
	    		subject
	    	}

	    	it {
	    		expect(Scan).not_to receive(:process_file).with(tex_path, false)
	    		subject
	    	}

		end

		# describe "#process_file" do
		# 	before(:each) do
		# 		setup_file('tmp/template.tex')
		# 		setup_file('tmp/template.pdf')				
		# 		@tex_path = 'tmp/template.tex'
		# 		@back_tex_path = @tex_path + '.backup'
		# 		@cui = Pmlatex::Add.new(myout, [@tex_path])
		# 		@cui.process_file(@tex_path)
		# 		@tex = Tex.from_file(@tex_path)
		# 		@bib = MedusaRestClient::Record.find(@tex.bib_id)
		# 	end

		# 	it { expect(@tex.bib_id).not_to be_nil }
		# 	it { expect(@bib.name).to eq(@tex.title) }
		# 	it "backup original tex-file" do
		# 		expect(File.exists?(@back_tex_path)).to be_truthy
		# 	end
		# end
		# after(:each) do
		# 	@bib.destroy
		# 	FakeWeb.allow_net_connect = false
		# end
	end
end