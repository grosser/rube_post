require 'mechanize'
require 'nokogiri'

class RubePost
  VERSION = File.read( File.join(File.dirname(__FILE__),'..','VERSION') ).strip
  URL = "https://portal.epost.de"

  def initialize(username, password)
    @username = username
    @password = password
  end

  def emails_in_inbox
    inbox, agent = login
    emails = self.class.find_emails_in_inbox(inbox.send(:html_body))
    emails.map{|d| Email.new(d, agent) }
  end

  private

  def self.find_emails_in_inbox(html)
    doc = Nokogiri::HTML(html)
    mails = doc.css('#messageList > tr')[1..-1]
    mails.map do |mail|
      {
        :id => mail.attr('id'),
        :sender => extract_sender(mail),
        :subject => mail.css('td.subject').text.strip
      }
    end
  end

  def self.extract_sender(mail)
    name, email = mail.css('td.sender a').text.strip.match(/(.*)\s+<(.*)>/)[1..-1]
    email
  end

  def login
    @agent ||= begin
      agent = Mechanize.new
      page = agent.get("#{URL}/login")
      login_form = page.forms.first
      login_form.field_with('username').value = @username
      login_form.field_with('password').value = @password
      inbox = login_form.submit
      [inbox, agent]
    end
  end

  class Email
    SHOW_URL = "https://portal.epost.de/mail/mailbox/view?msgStart=&messages="

    attr_reader :id, :sender, :subject

    def initialize(data, agent)
      @id = data[:id]
      @sender = data[:sender]
      @subject = data[:subject]
      @agent = agent
    end

    def content
      @content ||= begin
        body = @agent.get("#{SHOW_URL}#{id.gsub('/','%2F')}").send(:html_body)
        Nokogiri::HTML(body).css('#e-post-body').first.text.strip
      end
    end
  end
end