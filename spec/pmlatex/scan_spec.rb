require 'spec_helper'

module Pmlatex
  describe Scan do
#   let(:output) { double('output').as_null_object }
    before(:each) do
#     FakeWeb.allow_net_connect = true
#     setup_medusa
      setup_empty_dir('tmp')
    end

    describe "parse_texlog" do
      subject { Scan.parse_texlog(log_path) }
      let(:log_path) { 'tmp/template.log' }
      before(:each) do
        setup_file(log_path)
      end

#       it "does something" do
#         expect(subject.include_files).to include("C:\\Users\\sisyphus\\xtreeml\\orochi\\tmp\\template.tex")
# #       p log.include_files
#       end
      context "with no_such_file.log" do
        let(:log_path) { 'tmp/no_such_file.log' }
        it { expect(subject.include_files).to include("./report.tex") }
      end
    end

    describe ".rcheck_cite", :current => true do
      subject {Pmlatex::Scan.rcheck_cite(@ids, @tex)}
      before do
        @tex = double("tex")
        @tex.stub(:include_files).and_return(['sub-1'])
        allow(Pmlatex::Scan).to receive(:check_cite).and_return(["1", "2", "3"])
        @ids = ["1","2","3"]
      end
      
      it {
        expect{ subject }.not_to raise_error
      }
    end

    describe "#process_file" do
      let(:bib){ FactoryGirl.build(:bib, id: 10) }
      before(:each) do
        @tex_path = 'tmp/template.tex'
        @pdf_path = 'tmp/template.pdf'
        #@include_files = ['tmp/section1.tex', 'tmp/paragraph1.tex']
        setup_file(@tex_path)
        setup_file(@pdf_path)
        #@include_files.each do |include_file|
        #  setup_file(include_file)
        #end

        Dir.chdir('tmp')
        @tex_path = File.basename(@tex_path)
        #cmd = "pdflatex #{File.basename(@tex_path)}"
        #system(cmd)
        #system(cmd)
        
        #setup_file('tmp/template.pdf')
        @ss_path = 'tmp/template.ss'
        @back_tex_path = @tex_path + '.backup'
        @copy_tex_path = @tex_path + '.copy'
        @ss_path = File.basename(@tex_path,".tex") + '.ss'
        @cui = Pmlatex::Add.new(myout, [@tex_path])
        @cui.process_file(@tex_path)
        @tex = Tex.from_file(@tex_path)
        @bib = MedusaRestClient::Record.find(@tex.bib_id)
        # setup_medusa
        # setup_file('tmp/template-with-id.tex')
        # setup_file('tmp/template-with-id.pdf')        
        # @tex_path = 'tmp/template-with-id.tex'
        # @ss_path = 'tmp/template-with-id.ss'
        # @tex = Tex.from_file(@tex_path)
        @cui = Pmlatex::Scan.new(myout, [@tex_path])
        @cui.process_file(@tex_path)        
      end

      #it "generate ss-file" do
      #  expect(File.exists?(@ss_path)).to be_truthy
      #end
      xit "do something" do
        expect(nil).to be_nil
      end
      after(:each) do
      # @bib.destroy
      #  FakeWeb.allow_net_connect = false
      end   

    end
  end
end
