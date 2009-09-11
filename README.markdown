README for smail-mime
=====================

SMail::MIME is an extention of the SMail gem to handle MIME encoded email. It is
based on Perl's Email::MIME.

It implements the minimal functions to enable the easy creation or parsing of a
MIME email message that conforms to the relevant RFCs.

It is still a work in progress and the interface may change.

Download & Install
==================

    sudo gem install smail-mime-mwalker --source http://gems.github.com

Synopsis
========

    email = SMail::MIME.new(text)

    from_header = email.header("From")
    received = email.headers("Received")

    email.header_set("From", "matthew@walker.wattle.id.au")

    old_body = email.body
    email.body = "Hello World!\nMatthew"

    print email.to_s


Contributors
============

SMail::MIME is maintained by Matthew Walker
[matthew@walker.wattle.id.au](mailto:matthew@walker.wattle.id.au)

Contributors include:

[Pete Yandell](http://github.com/notahat)

Thanks to the [Perl Email Project](http://emailproject.perl.org/)'s [Email::MIME](http://emailproject.perl.org/wiki/Email::MIME)
