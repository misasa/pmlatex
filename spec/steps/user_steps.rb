
step "I am not yet playing" do

end

step "I have set up medusa" do
  setup_medusa
end

step "I have a empty directory :dirname" do |dirname|
  deleteall(dirname) if File.directory?(dirname)
  FileUtils.mkdir_p(dirname) unless File.directory?(dirname)
end

step "I have a file :filename" do |arg1|
  setup_file(arg1)
end

step "I changed directory :path" do |path|
  Dir.chdir(path)
end

step "I should have a file :path" do |path|
  expect(File.exists?(path)).to be_truthy
end

step "I start pmlatex with :arg" do |arg|
  p arg
  @argv = Shellwords.split(arg)
  @app = Pmlatex::App.init(myout,@argv)
  @app.start
end

step "I should see :message" do |message|
  expect(myout.messages).to include(message)
end

# step "I split a file :filename" do |path|
#   @app = Casteml::App.init(output, ['split', path])
#   #@cui = Casteml::Split.new(output)
#   #@cui.process_file(path)
#   @app.start
# end

# step "I start join with :argl" do |argl|
#   @argv = Shellwords.split(argl)
#   @cui = Casteml::Join.new(output, {}, @argv)
#   @cui.start
# end

