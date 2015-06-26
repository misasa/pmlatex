require 'spec_helper'

module Pmlatex
	describe OverPic do
		before(:each) do
		end
		describe "#put_isoclock" do
			before(:each) do
				@overpic = Pmlatex::OverPic.new
				@x_image = 10.2
				@y_image = 22.3
				@isotope = -2.3
			end

			it "put something" do
				tex = @overpic.put_isoclock(@x_image, @y_image, @isotope)
				expect(tex).to be_an_instance_of(String)
#				expect(File.exists?(@tex_path)).to be_truthy
			end
		end
	end
end