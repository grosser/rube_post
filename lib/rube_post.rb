require 'mechanize'
require 'nokogiri'

class RubePost
  VERSION = File.read( File.join(File.dirname(__FILE__),'..','VERSION') ).strip

  def initialize(username, password)
    @grabber = Grabber.new(username, password)
  end

  def emails_in_inbox
    @grabber.emails_in_inbox.map{|d| Email.new(d, @grabber) }
  end

  private

  class Grabber
    URL = "https://portal.epost.de"
    SHOW_URL = "#{URL}/mail/mailbox/view?msgStart=&messages="

    def initialize(username, password)
      @agent = Mechanize.new
      page = @agent.get("#{URL}/login")
      login_form = page.forms.first
      login_form.field_with('username').value = username.sub(/@.*/,'')
      login_form.field_with('password').value = password
      @inbox = login_form.submit
      @agent
    end

    def emails_in_inbox
      doc = Nokogiri::HTML(@inbox.send(:html_body))
      mails = doc.css('#messageList > tr')[1..-1] || raise('could not open inbox <-> login failed ?')
      mails.map do |mail|
        {
          :id => mail.attr('id'),
          :sender => self.class.extract_sender(mail),
          :subject => mail.css('td.subject').text.strip
        }
      end      
    end

    def email_content(id)
      body = @agent.get("#{SHOW_URL}#{id.gsub('/','%2F')}").send(:html_body)
      Nokogiri::HTML(body).css('#e-post-body').first.text.strip
    end

    def move_to_trash(id)
      form = @inbox.forms.detect{|f| f.name == 'messages' }
      checkbox = form.checkboxes.detect{|c| c.value == id }
      checkbox.check
      button = form.buttons.detect{|b| b.name == 'cmd[delete-message]'}
      @agent.submit(form, button)
    end

    private

    def self.extract_sender(mail)
      name, email = mail.css('td.sender a').text.strip.match(/(.*)\s+<(.*)>/)[1..-1]
      email
    end
  end

  class Email
    attr_reader :id, :sender, :subject

    def initialize(data, grabber)
      @id = data[:id]
      @sender = data[:sender]
      @subject = data[:subject]
      @grabber = grabber
    end

    def content
      @grabber.email_content(@id)
    end

    def move_to_trash
      @grabber.move_to_trash(@id)
    end
  end
end