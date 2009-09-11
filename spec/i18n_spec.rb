# $Id: email_controller.rb 856 2006-10-26 03:09:39Z pete $
# vim: ts=2 sw=2 ai expandtab

require File.dirname(__FILE__) + '/../lib/smail/mime'
require File.dirname(__FILE__) + '/spec_helper'

describe "SMail::MIME.encode_field" do

  before do
    @s = "Test de contr\303\264le effectu\303\251"
  end

  it "should encode to a quoted-printable encoded field" do
    SMail::MIME.encode_field(@s).should eql("=?UTF-8?Q?Test_de_contr=C3=B4le_effectu=C3=A9?=")
  end

  it "should encode to a base64 encoded field" do
    SMail::MIME.encode_field(@s, :base64).should eql("=?UTF-8?B?VGVzdCBkZSBjb250csO0bGUgZWZmZWN0dcOp?=")
  end

  # FIXME: some weird difference with class method raises vs. instance method raises
  #it "should raise an error when attempting to encode to an invalid encoding" do
  #  lambda{SMail::MIME.encode_field(@s, :invalid)}.should \
  #    raise_error(ArgumentError, 'Bad MIME Encoding')
  #end

  it "should encode to a quoted-printable field using the iso-8859-1 charset" do
    SMail::MIME.encode_field(@s, :quoted_printable, 'iso-8859-1').should \
      eql("=?ISO-8859-1?Q?Test_de_contr=F4le_effectu=E9?=")
  end

  it "should encode to a base64 encoded field using the iso-8859-1 charset" do
    SMail::MIME.encode_field(@s, :base64, 'iso-8859-1').should \
      eql("=?ISO-8859-1?B?VGVzdCBkZSBjb250cvRsZSBlZmZlY3R16Q==?=")
  end

  it "should not split a multibyte character between encoded_fields" do
    # FIXME:
    
  end 

end

describe "SMail::MIME.encode_field and SMail::MIME.decode_field" do

  it "should be able to be used in a circular fashion" do
    # FIXME:
  end

end

describe "A SMail::MIME object" do
  before do
    @message = SMail::MIME.new
  end

  it "should be able to have its subject changed to a UTF-8 string" do
    @message.subject = "계희정"
    @message.subject.should eql("계희정")
  end

  it "should reflect changes in the subject in the raw subject" do
    @message.subject = "계희정"
    @message.subject_raw.should eql("=?UTF-8?B?6rOE7Z2s7KCV?=")
  end

end

describe "A SMail::MIME object parsed from a Chinese spam message" do
  include SMailMIMEHelperMethods

  before do
    @message = SMail::MIME.new(email_text_from_file('chinese'))
  end

  it "should be a SMail::MIME object" do
    @message.should be_an_instance_of(SMail::MIME)
  end

  it "should have a subject of '<年.终.的.绩.效.考.核>卢先生'" do
    @message.subject.should eql("<年.终.的.绩.效.考.核>卢先生")
  end

  it "should correctly convert the charset of the body to UTF-8" do
    @message.body.split("\n")[2].should eql("          隆露锚..录篓.搂.鹿.铆.碌.陆.录录..么隆掳K P I+B S C隆卤碌陆隆路")
  end

end
