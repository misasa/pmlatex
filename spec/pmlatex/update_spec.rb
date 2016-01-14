require 'spec_helper'
require 'medusa_rest_client'
module Pmlatex
	describe Update do
		before(:each) do
#			FakeWeb.allow_net_connect = true
#			setup_medusa
			setup_empty_dir('tmp')
		end
		describe "#process_file" do
			subject{ cui.process_file(tex_path) }
			let(:cui) { Pmlatex::Update.new(myout, [tex_path])}
			let(:tex_path){ 'tmp/template.tex'}
			let(:pdf_path){ 'tmp/template.pdf'}
			let(:updated_title){ "Updated title"}
			let(:tex){ double("tex", :bib_id => "0000-001", :author_fullnames => [], :title => "hello world", :year => 2014, :mon => 4) }
			let(:bib){ double("bib", :author_ids => [], :name => "hello world", :year => 2014, :month => 4)}
			before(:each) do
				setup_file(tex_path)
				setup_file(pdf_path)				
				allow(tex).to receive(:parse_author).and_return(nil)
				allow(Tex).to receive(:from_file).and_return(tex)
				allow(MedusaRestClient::Record).to receive(:find).and_return(bib)

				# @tex_path = 'tmp/template.tex'
				# @back_tex_path = @tex_path + '.backup'
				# @copy_tex_path = @tex_path + '.copy'
				# @cui = Pmlatex::Add.new(myout, [@tex_path])
				# @cui.process_file(@tex_path)
				# @tex = Tex.from_file(@tex_path)
				# @bib = MedusaRestClient::Record.find(@tex.bib_id)

				# FileUtils.copy_file(@tex_path, @copy_tex_path)
				# src = File.open(@copy_tex_path).read
				# src.sub!(/\\title{title}/, "\\title{#{updated_title}}")
				# File.open(@tex_path, "w"){|f|
				# 	f.puts src
				# }
				# @cui = Pmlatex::Update.new(myout, [@tex_path])
				# @cui.process_file(@tex_path)
			end
			it { 
				expect(Tex).to receive(:from_file).with(tex_path, false).and_return(tex)
				subject
			}
			#it { expect(@bib.global_id).to eq(@tex.bib_id) }
			#it { expect(MedusaRestClient::Record.find(@bib.global_id).name).to eq(updated_title) }

		end
		# after(:each) do
		# 	@bib.destroy
		# 	FakeWeb.allow_net_connect = false
		# end		
	end
end
