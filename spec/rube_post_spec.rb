require File.expand_path('spec/spec_helper')

describe RubePost do
  it "has a VERSION" do
    RubePost::VERSION.should =~ /^\d+\.\d+\.\d+$/
  end

  describe 'fetch' do
    before :all do
      @emails = RubePost.new(CFG['username'], CFG['password']).emails_in_inbox
    end

    # if you do not have mails, ask a question to support -> you get a mail
    it "can fetch mail" do
      @emails.size.should >= 0
      @emails.first.id.should =~ %r{^\d+$}
      @emails.first.subject.to_s .should_not == ''
      @emails.first.sender.should include('@')
    end

    it "can get the content" do
      @emails.first.content.size.should >= 100
    end
  end
end