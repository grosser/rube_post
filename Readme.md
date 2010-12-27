Receive and send(todo) emails with epost.de (pronounced rub-e-post)

Install
=======
    sudo gem install rube_post

!! Set your account to list-view !!

Usage
=====
    client = RubePost.new(username, password)
    emails = client.emails_in_inbox

    mail = emails.first
    puts mail.sender
    puts mail.content # triggers new request
    puts mail.subject
    puts mail.id

    mail.move_to_trash

Move all mails to gmail.
    gem install gmail
    RubePost.new(username, password).move_to_gmail(gmail_username, gmail_password)

TODO
=====
 - work for more than first page of inbox
 - send mails ? <-> let user enter tan or receive tan via some service


Author
======
[Michael Grosser](http://grosser.it)  
grosser.michael@gmail.com  
Hereby placed under public domain, do what you want, just do not hold me accountable...
