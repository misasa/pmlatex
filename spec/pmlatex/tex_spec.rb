require 'spec_helper'

module Pmlatex
  describe Tex do
    before(:each) do
      setup_empty_dir('tmp')
    end

    describe "from_file", :current => true do
      before(:each) do
        setup_file('tmp/yamanaka_report.tex')
        @tex_path = 'tmp/yamanaka_report.tex'
      end

      it "does something" do
        tex = Tex.from_file(@tex_path)
      end
    end


    describe "#parse" do
      let(:tex) { Pmlatex::Tex.new(src) }
      context "with author" do
        let(:author_tag) {'Yachi, Y.'}      
        let(:src) { "\n\\author{#{author_tag}}"}
        before do
          tex.parse
        end
        it { expect( tex.author ).to eql(author_tag)}
      end

      context "with citeyearpar" do
        let(:src){'
OVZc-c \citeyearpar{20140808090748-453379} & OVZc-c-L1 \citeyearpar{20140808090814-129194} \\
        '}
        before do
          tex.parse
        end
        it { expect(tex.citeyearpars.size).to be_eql(2)}
      end

      context "with citep" do
        let(:src){'
OVZc-c \citep{20140808090748-453379} & OVZc-c-L1 \citep{20140808090814-129194} \\
        '}
        before do
          tex.parse
        end
        it { expect(tex.citeps.size).to be_eql(2)}
      end

      context "with cite" do
        let(:src){'
OVZc-c \cite{20140808090748-453379} & OVZc-c-L1 \cite{20140808090814-129194} \\
        '}
        before do
          tex.parse
        end
        it { expect(tex.cites.size).to be_eql(2)}
      end

    end
    describe "#parse_author" do
      let(:tex) { Pmlatex::Tex.new(src) }
      let(:src) { 'hello tex'}
      before do
        tex.author = author
        tex.parse_author
      end
      context "Last1, Y." do
        let(:author){'Nakamura, E.'}
        it { expect(tex.authors).to include({:lastname => 'Nakamura', :firstname => 'E.'})}
      end
      context "YS and TK" do
        let(:author){'YS and TK'}
        it { expect(tex.authors).to include({:lastname => 'YS'})}
      end
      context "Last1, A., Last2, B., and Last3, C." do
        let(:author){'Nakamura, E., Makishima, A., Moriguti, T., Kobayashi, K., Tanaka, R., Kunihiro, T., Tsujimori, T., Sakaguchi, C., Kitagawa, H., Ota, T., Yachi, Y., Yada, T., Abe, M., Fujimura, A., Ueno, M., Mukai, T., Yoshikawa, M., and Kawaguchi, J.'}
        it { expect( tex.authors ).to include({:lastname => 'Nakamura', :firstname => 'E.'}) }
      end
      context "Last1, A. B., Last2, B., and Last3, C." do
        let(:author){'Last1, A. B., First1 Jr. Last1, Yusuke Yachi, Tak Kunihiro, and Last2, D.'}
        it { expect( tex.authors ).to include({:lastname => 'Yachi', :firstname => 'Yusuke'}) }
        it { expect( tex.author_fullnames ).to include('Last1, A. B.')}
      end

    end
  end
end
