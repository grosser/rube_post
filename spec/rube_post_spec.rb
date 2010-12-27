require File.expand_path('spec/spec_helper')

describe RubePost do
  it "has a VERSION" do
    RubePost::VERSION.should =~ /^\d+\.\d+\.\d+$/
  end
end
