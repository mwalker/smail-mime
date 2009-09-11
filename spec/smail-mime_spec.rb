# $Id: email_controller.rb 856 2006-10-26 03:09:39Z pete $
# vim: ts=2 sw=2 ai expandtab

require File.dirname(__FILE__) + '/../lib/smail/mime'
require File.dirname(__FILE__) + '/spec_helper'

require 'digest/md5'

describe "A SMail::MIME object" do
  before do
    @message = SMail::MIME.new
  end

  it "should be a SMail::MIME object" do
    @message.should be_an_instance_of(SMail::MIME)
  end

  it "should default to a line ending of CRLF" do
    @message.crlf.should eql("\r\n")
  end

  it "should default to a Content-Type of 'text/plain; charset=us-ascii'" do
    @message.content_type.to_s.should eql('text/plain; charset=us-ascii')
  end

end

describe "A SMail::MIME object created by parsing the bare minimum to form an email" do
  include SMailMIMEHelperMethods

  before do
    @message = SMail::MIME.new(email_text_from_file('bare'))
  end

  it "should be a SMail::MIME object" do
    @message.should be_an_instance_of(SMail::MIME)
  end

  it "should have a MIME-Version of 1.0" do
    @message.version.should eql('1.0')
  end

  it "should have an empty content_type" do
    @message.content_type.type_raw.should be_nil
  end

  it "should be 92 bytes in size" do
    @message.size.should eql(74)
  end

  it "should not have a subject" do
    @message.subject.should be_nil
  end

  it "should not have a date" do
    @message.date.should be_nil
  end

  it "should have an empty body" do
    @message.body.should be_empty
  end

end

describe "A SMail::MIME object created by parsing a very simple email" do
  include SMailMIMEHelperMethods

  before do
    @message = SMail::MIME.new(email_text_from_file('simple'))
  end

  it "should be a SMail::MIME object" do
    @message.should be_an_instance_of(SMail::MIME)
  end

  it "should have a MIME-Version of 1.0" do
    @message.version.should eql('1.0')
  end

  it "should have no parts" do
    @message.parts.should be_empty
  end

  it "should not be multipart" do
    @message.multipart?.should be_false
  end
  
  it "should have a Content-Type of 'text/plain; charset=US-ASCII'" do
    @message.content_type.to_s.should eql('text/plain; charset=US-ASCII')
  end

  it "should not have a content-transfer-encoding header" do
    @message.header('content-transfer-encoding').should be_nil
  end

  it "should have a mime structure of 'text/plain'" do
    @message.describe_mime_structure.should eql('text/plain')
  end

  it "should have a subject of 'A simple email.'" do
    @message.subject.should eql('A simple email.')
  end

  it "should have a raw subject of 'A simple email.'" do
    @message.subject_raw.should eql('A simple email.')
  end

  it "should be able to have its subject changed" do
    @message.subject = 'A modified simple email.'
    @message.subject.should eql('A modified simple email.')
    @message.subject_raw.should eql('A modified simple email.')
  end

  it "should be able to have its raw subject changed" do
    @message.subject_raw = 'A modified simple email.'
    @message.subject.should eql('A modified simple email.')
    @message.subject_raw.should eql('A modified simple email.')
  end

  it "should have a date of 'Thu, 02 Oct 2003 05:07:13 +0000'" do
    @message.date.to_s.should eql('Thu, 2 Oct 2003 05:07:13 +0000')
  end

  it "should have a size of 253 bytes" do
    @message.size.should eql(253)
  end

  it "should have a body of 'A simple boring email\n'" do
    @message.body.should eql("A simple boring email.\n")
  end

end

describe "A SMail::MIME object created by parsing an email with an attachment" do
  include SMailMIMEHelperMethods

  before do
    @message = SMail::MIME.new(email_text_from_file('attachment'))
  end

  it "should be a SMail::MIME object" do
    @message.should be_an_instance_of(SMail::MIME)
  end

  it "should have a date of 'Thu, 26 Apr 2007 20:49:54 +1000'" do
    @message.date.to_s.should eql('Thu, 26 Apr 2007 20:49:54 +1000')
  end

  it "should have a MIME-Version of 1.0" do
    @message.version.should eql('1.0')
  end

  it "should be multipart" do
    @message.multipart?.should be_true
  end

  it "should have 2 parts" do
    @message.parts.length.should eql(2)
  end

  it "should have a preamble of 'This is a MIME message.'" do
    @message.preamble.should eql("This is a MIME message.\n\n")
  end

  it "should have an epilogue of 'Epilogue!!\n'" do
    @message.epilogue.should eql("Epilogue!!\n")
  end

  it "should have a first part with a Content-Type of 'text/plain; charset=ISO-8859-1'" do
    @message.parts.first.content_type.to_s.should eql('text/plain; charset=ISO-8859-1')
  end

  it "should have a second part with a Content-Type of 'image/png; name=Home.png'" do
    @message.parts[1].content_type.to_s.should eql('image/png; name=Home.png')
  end
  
  it "should have a mime structure of 'multipart/mixed\n  text/plain\n  image/png'" do
    @message.describe_mime_structure.should eql("multipart/mixed\n  text/plain\n  image/png")
  end

  it "should be able to be flattened" do
    flattened = @message.flatten_body('text/plain', /^image\/.*$/)
    flattened.length.should eql(2)
  end

  it "should have a body that is the preamble" do
    @message.body.should eql("This is a MIME message.\n\n")
    @message.body.should eql(@message.preamble)
  end

  it "should be able to decode the body of the first part" do
    @message.parts.first.body.should eql("Home is where the file is.\n\nSend instant messages to your online friends http://au.messenger.yahoo.com \n")
  end

  it "should be able to decode the body of the second (image) part" do
    Digest::MD5.hexdigest(@message.parts[1].body).should eql('c2281ab101237a3a929ab5af3d48a7e4')
  end

end
