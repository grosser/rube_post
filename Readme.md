Receive and send(todo) emails with epost.de (rub-e-post)

Install
=======
    sudo gem install rube_post

 - Set your account to list-view/

Usage
=====
    emails = RubePost.new(username, password).emails_in_inbox
    first = emails.first
    puts first.sender
    puts first.content # will make an additional request
    puts first.subject
    puts first.id

TODO
=====
 - send mails ? <-> let user enter tan or receive tan via some service
 - move_to_trash / delete mails


Author
======
[Michael Grosser](http://grosser.it)  
grosser.michael@gmail.com  
Hereby placed under public domain, do what you want, just do not hold me accountable...
