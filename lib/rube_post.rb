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

  def move_to_gmail(username, password)
    require 'gmail'
    my_email = (username.include?('@') ? username : "#{username}@gmail.com")
    Gmail.connect(username, password) do |gmail|
      emails_in_inbox.each do |email|
        gmail.deliver do
          to my_email
          subject email.subject
          text_part do
            body "#{email.sender}:\nepost-id:#{email.id}\n\n#{email.content}"
          end
        end
        email.move_to_trash
      end
    end
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
      @account = messages_form.action.match(/(\d{10,})/)[1]
      @agent
    end

    def emails_in_inbox
      doc = Nokogiri::HTML(@inbox.send(:html_body))
      mails = doc.css('#messageList > tr')[1..-1] || raise('could not open inbox <-> login failed ?')
      mails.map do |mail|
        {
          :id => mail.attr('id').split('/').last,
          :sender => self.class.extract_sender(mail),
          :subject => mail.css('td.subject').text.strip
        }
      end
    end

    def email_content(id)
      body = @agent.get("#{SHOW_URL}#{full_id(id).gsub('/','%2F')}").send(:html_body)
      Nokogiri::HTML(body).css('#e-post-body').first.text.strip
    end

    def move_to_trash(id)
      form = messages_form
      checkbox = form.checkboxes.detect{|c| c.value == full_id(id) }
      checkbox.check
      button = form.buttons.detect{|b| b.name == 'cmd[delete-message]'}
      page = @agent.submit(form, button)
      checkbox.uncheck # revert checking or something might o wrong later...
      page
    end

    private

    def full_id(id)
      "/#{@account}/INBOX/#{id}"
    end

    def messages_form
      @inbox.forms.detect{|f| f.name == 'messages' }
    end

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