require 'spec_helper'
module Pmlatex
	describe TexLog do

		describe ".scan_tex_path", :current => true do
			subject { TexLog.scan_tex_path(src) }
			context "with log" do
				let(:log_path) { 'tmp/no_such_file.log' }
				let(:src){ File.open(log_path).read }
				before(:each) do
					setup_empty_dir('tmp')
					setup_file(log_path)
				end

				it { expect(subject).to include("./report.tex")}
				it { expect(subject).to include("./mount/figure0.tex")}
				it { expect(subject).to include("./mount/origin.tex")}
			end

			context "with empty src" do
				let(:src){ "" }

				it { expect(subject).to eql([])}
			end

			context "with nil src" do
				let(:src){ nil }

				it { expect(subject).to be_nil }
			end

		end

		describe "parse_texlog" do
			subject { TexLog.from_file(log_path) }
			let(:log_path) { 'tmp/no_such_file.log' }
			before(:each) do
				setup_empty_dir('tmp')
				setup_file(log_path)
			end

			it "does something" do
				expect(subject.include_files).to include("./report.tex")
			end
		end

	end
end