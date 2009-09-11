require File.dirname(__FILE__) + '/../lib/smail/mime'
require File.dirname(__FILE__) + '/spec_helper'

describe "A SMail::MIME built from scratch" do
  include SMailMIMEHelperMethods
  before do
    @message = SMail::MIME.new()
  end

  it "should be a SMail::MIME object" do
    @message.should be_an_instance_of(SMail::MIME)
  end

  it "should allow the setting of the Content-Type" do
    @message.content_type = 'text/plain'
    @message.content_type.should be_an_instance_of(SMail::MIME::ContentType)
  end

  # FIXME: or should we just default to UTF-8 and be less flexible?
  it "should default to a charset of 'US-ASCII' if one is not set" # do
  #  @message.content_type.params['charset'].should == 'US-ASCII'
  #end

  it "should accept a charset that is specified in the charset param of the content-type" do
    @message.content_type = 'text/plain; charset=UTF-8'
    @message.content_type.params['charset'].should == 'UTF-8'
  end

  it "should create a boundary for a content-type of multipart if one is not set" do
    @message.content_type = 'multipart/alternative'
  end

  it "should include the content-type in the headers when it has been set"

  it "should include the MIME-Version header in the headers with version 1.0 if it has not been set"

  it "should encode the subject when it is set"

  it "should allow the setting of the subject_raw directly"

  it "should allow the setting of the date"

  it "should allow the setting of the body_raw directly"

  it "should encode the body when it is set"

  it "should build the message out of multiple parts" # do
  #  @message.content_type = 'multipart/alternative; boundary=ABCDEF'
  #  text_part = SMail::MIME.new
  #  text_part.content_type = 'text/plain; charset=UTF-8'
  #  text_part.body = "This is the text part."
  #
  #  html_part = SMail::MIME.new
  #  html_part.content_type = 'text/html; charset=UTF-8'
  #  html_part.body = "<h1>This is the HTML part.</h1>"
  #
  #  @message.parts << text_part << html_part
  #
  #  puts @message.parts.inspect
  #
    # Don't use .should !=, it doesn't work
  #  @message.to_s.should_not == "\r\n\r\n"
  #end

end
