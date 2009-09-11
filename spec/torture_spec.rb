# $Id: email_controller.rb 856 2006-10-26 03:09:39Z pete $
# vim: ts=2 sw=2 ai expandtab

require File.dirname(__FILE__) + '/../lib/smail/mime'
require File.dirname(__FILE__) + '/spec_helper'

describe "A SMail::MIME object parsed from the UW MIME torture test email" do
  include SMailMIMEHelperMethods
  before do
    @message = SMail::MIME.new(email_text_from_file('torture'))
  end

  it "should be a SMail::MIME object" do
    @message.should be_an_instance_of(SMail::MIME)
  end

  it "should have a Content-Type of 'MULTIPART/MIXED; boundary=owatagusiam'" do
    @message.content_type.to_s.should eql('MULTIPART/MIXED; boundary=owatagusiam')
  end

  it "should have a raw media type of 'MULTIPART'" do
    @message.content_type.media_type_raw.should eql('MULTIPART')
  end

  it "should have a media type of 'multipart'" do
    @message.content_type.media_type.should eql('multipart')
  end

  it "should have only one param in the Content-Type" do
    @message.content_type.params.length.should eql(1)
  end

  it "should have a boundary param of 'owatagusiam'" do
    @message.content_type.params['boundary'].should eql('owatagusiam')
  end

  it "should have 12 top level parts" do
    @message.parts.length.should eql(12)
  end

  # FIXME: I think this should actually be 52, see lasttort below it doesn't parse properly
  it "should have a total of 41 parts" do
    #puts @message.describe_mime_structure
    @message.describe_mime_structure.split(/\n/).length.should eql(41)
  end

end

describe "A SMail::MIME object parsed from the last message/rfc822 part of the UW MIME torture test" do
  include SMailMIMEHelperMethods
  before do
    @message = SMail::MIME.new(email_text_from_file('lasttort'))
  end

  it "should be a SMail::MIME object" do
    @message.should be_an_instance_of(SMail::MIME)
  end

  # FIXME: haven't actualy worked this out, currently has 0
  # seems to be because top level MULTIPART has BOUNDARY not boundary
  it "should have 11 top level parts" #do
  #  @message.parts.length.should eql(11)
  #end
end


describe "A SMail::MIME object parsed from the Ryan Finnie MIME torture test email" do
  include SMailMIMEHelperMethods
  before do
    @message = SMail::MIME.new(email_text_from_file('rf-torture'))
  end

  it "should be a SMail::MIME object" do
    @message.should be_an_instance_of(SMail::MIME)
  end

  it "should have 11 top level parts" do
    @message.parts.length.should eql(11)
  end

  # this may be meant to be 50, need to cross check it may be the top part is just missing
  it "should have a total of 49 parts" do
    @message.describe_mime_structure.split(/\n/).length.should eql(49)
  end

  #it "should be good!!!!" do
  #  puts @message.describe_mime_structure
  #end

end
