require File.dirname(__FILE__) + '/../lib/smail/mime'
require File.dirname(__FILE__) + '/spec_helper'

describe "A SMail::MIME::ContentField object" do
  before do
    @content_field = SMail::MIME::ContentField.new
  end

  it "should be a SMail::MIME::ContentField object" do
    @content_field.should be_an_instance_of(SMail::MIME::ContentField)
  end

  it "should default to having a type of nil" do
    @content_field.type.should be_nil
  end

  it "should default to having no params" do
    @content_field.params.should be_empty
  end

  it "should have params that are a SMail::MIME::ContentField::Params object" do
    @content_field.params.should be_an_instance_of(SMail::MIME::ContentField::Params)
  end

end

describe "A SMail::MIME::ContentDisposition object" do
  before do
    @content_disposition = SMail::MIME::ContentDisposition.new
  end

  it "should be a SMail::MIME::ContentDisposition object" do
    @content_disposition.should be_an_instance_of(SMail::MIME::ContentDisposition)
  end

  it "should default to having a type of nil" do
    @content_disposition.type.should be_nil
  end

  it "should default to having no params" do
    @content_disposition.params.should be_empty
  end

  it "should have params that are a SMail::MIME::ContentDisposition::Params object" do
    @content_disposition.params.should be_an_instance_of(SMail::MIME::ContentDisposition::Params)
  end

  it "should default to not being an attachment" do
    @content_disposition.attachment?.should be_false
  end

  it "should default to not being inline" do
    @content_disposition.inline?.should be_false
  end

  it "should allow the setting of the type" do
    @content_disposition.type = 'inline'
    @content_disposition.type.should eql('inline')
  end

  it "should default when being written as a string to being an attachment" do
    @content_disposition.to_s.should eql('attachment')
  end

  it "should allow the setting of params" do
    @content_disposition.params['filename'] = 'fred.txt'
    @content_disposition.to_s.should eql('attachment; filename=fred.txt')
  end

end

describe "A SMail::MIME::ContentType object" do
  before do
    @content_type = SMail::MIME::ContentType.new
  end

  it "should be a SMail::MIME::ContentType object" do
    @content_type.should be_an_instance_of(SMail::MIME::ContentType)
  end

  it "should default to having no params" do
    @content_type.params.should be_empty
  end

  it "should have params that are a SMail::MIME::ContentType::Params object" do
    @content_type.params.should be_an_instance_of(SMail::MIME::ContentType::Params)
  end

  it "should default to having a media type of nil" do
    @content_type.media_type.should be_nil
  end

  it "should default to having a media subtype of nil" do
    @content_type.media_subtype.should be_nil
  end

  it "should default to having a type of 'text/plain'" do
    @content_type.type.should eql('text/plain')
  end

  it "should default to a content-type of 'text/plain; charset=us-ascii'" do
    @content_type.to_s.should eql('text/plain; charset=us-ascii')
  end

  it "should default to being discrete" do
    @content_type.discrete?.should be_true
  end

  it "should default to not being composite" do
    @content_type.composite?.should be_false
  end

  it "should allow the setting of the media type" do
    @content_type.media_type = 'application'
    @content_type.media_type.should eql('application')
  end

  it "should default to having a type of text/plain when only the media type is set" do
    @content_type.media_type = 'application'
    @content_type.type.should eql('text/plain')
  end

  it "should allow the setting of media subtype" do
    @content_type.media_subtype = 'octet-stream'
    @content_type.media_subtype.should eql('octet-stream')
  end

  it "should default to having a type of text/plain when only the media subtype is set" do
    @content_type.media_subtype = 'octet-stream'
    @content_type.type.should eql('text/plain')
  end

  it "should not use the default type when then media type and subtype are set" do
    @content_type.media_type = 'application'
    @content_type.media_subtype = 'octet-stream'
    @content_type.type.should eql('application/octet-stream')
  end

  it "should return type as a lower case string even if the media type and/or subtype are upper case" do
    @content_type.media_type = "APPLICATION"
    @content_type.media_subtype = "X-GZIP"
    @content_type.type.should eql('application/x-gzip')
  end

  it "should be composite when the media type is set to multipart" do
    @content_type.media_type = 'multipart'
    @content_type.composite?.should be_true
  end

  it "should not be discrete when the media type is set to multipart" do
    @content_type.media_type = 'multipart'
    @content_type.discrete?.should be_false
  end

  it "should be composite when the media type is set to MULTIPART" do
    @content_type.media_type = 'MULTIPART'
    @content_type.composite?.should be_true
  end

  it "should not be discrete when the media type is set to MULTIPART" do
    @content_type.media_type = 'MULTIPART'
    @content_type.discrete?.should be_false
  end

  it "should be composite when the media type is set to message" do
    @content_type.media_type = 'message'
    @content_type.composite?.should be_true
  end

  it "should not be discrete when the media type is set to message" do
    @content_type.media_type = 'message'
    @content_type.discrete?.should be_false
  end

  it "should be composite when the media type is set to MESSAGE" do
    @content_type.media_type = 'MESSAGE'
    @content_type.composite?.should be_true
  end

  it "should not be discrete when the media type is set to MESSAGE" do
    @content_type.media_type = 'MESSAGE'
    @content_type.discrete?.should be_false
  end

  it "should be discrete when the media type is set to image" do
    @content_type.media_type = 'image'
    @content_type.discrete?.should be_true
  end

  it "should not be composite when the media type is set to image" do
    @content_type.media_type = 'image'
    @content_type.composite?.should be_false
  end

  it "should be discrete when the media type is set to IMAGE" do
    @content_type.media_type = 'IMAGE'
    @content_type.discrete?.should be_true
  end

  it "should not be composite when the media type is set to IMAGE" do
    @content_type.media_type = 'IMAGE'
    @content_type.composite?.should be_false
  end

end

describe "A SMail::MIME::ContentType object parsed from 'text/plain'" do
  before do
    @content_type = SMail::MIME::ContentType.new('text/plain')
  end

  it "should be a SMail::MIME::ContentType object" do
    @content_type.should be_an_instance_of(SMail::MIME::ContentType)
  end

  it "should have a media type of text" do
    @content_type.media_type.should eql('text')
  end

  it "should have a media subtype of plain" do
    @content_type.media_subtype.should eql('plain')
  end

  it "should set params to a SMail::MIME::ContentType::Params object" do
    @content_type.params.should be_an_instance_of(SMail::MIME::ContentType::Params)
  end

  it "should have an empty set of params" do
    @content_type.params.empty?.should be_true
  end

  it "should be returned as a string with no params and no ; following the type" do
    @content_type.to_s.should eql('text/plain')
  end
end


describe "A SMail::MIME::ContentType object parsed from 'text/plain; charset=us-ascii'" do
  before do
    @content_type = SMail::MIME::ContentType.new('text/plain; charset=us-ascii')
  end

  it "should be a SMail::MIME::ContentType object" do
    @content_type.should be_an_instance_of(SMail::MIME::ContentType)
  end

  it "should have a media type of text" do
    @content_type.media_type.should eql('text')
  end

  it "should have a media subtype of plain" do
    @content_type.media_subtype.should eql('plain')
  end

  it "should set params to a SMail::MIME::ContentType::Params object" do
    @content_type.params.should be_an_instance_of(SMail::MIME::ContentType::Params)
  end

  it "should have params that have one entry" do
    @content_type.params.keys.length.should eql(1)
  end

  it "should have params with a key of charset and a value of us-ascii" do
    @content_type.params['charset'].should eql('us-ascii')
  end

  it "should be the same when returned as a string" do
    @content_type.to_s.should eql('text/plain; charset=us-ascii')
  end

  it "should be discrete" do
    @content_type.discrete?.should be_true
  end

  it "should not be composite" do
    @content_type.composite?.should be_false
  end
end

describe "A SMail::MIME::ContentType object parsed from 'text/plain; charset=us-ascii'" do
  before do
    @content_type = SMail::MIME::ContentType.new('text/plain; charset=us-ascii')
  end

  it "should be a SMail::MIME::ContentType object" do
    @content_type.should be_an_instance_of(SMail::MIME::ContentType)
  end

  it "should have a media type of text" do
    @content_type.media_type.should eql('text')
  end

  it "should have a media subtype of plain" do
    @content_type.media_subtype.should eql('plain')
  end

  it "should set params to a SMail::MIME::ContentType::Params object" do
    @content_type.params.should be_an_instance_of(SMail::MIME::ContentType::Params)
  end

  it "should have params that have one entry" do
    @content_type.params.keys.length.should eql(1)
  end

  it "should have params with a key of charset and a value of us-ascii" do
    @content_type.params['charset'].should eql('us-ascii')
  end

  it "should be the same when returned as a string" do
    @content_type.to_s.should eql('text/plain; charset=us-ascii')
  end

  it "should be discrete" do
    @content_type.discrete?.should be_true
  end

  it "should not be composite" do
    @content_type.composite?.should be_false
  end
end


describe "A SMail::MIME::ContentType object parsed from a Content-Type" do
  it "should unquote quoted values" do
    @content_type = SMail::MIME::ContentType.new('image/jpeg; name="example.jpg"')
    @content_type.params['name'].should eql('example.jpg')
  end

  it "should unquote quoted values containing quotes" do
    @content_type = SMail::MIME::ContentType.new('image/jpeg; name="\"quoted\" name.jpg')
    @content_type.params['name'].should eql('"quoted" name.jpg')
  end

  it "should unquote quoted values containing escapes" do
    @content_type = SMail::MIME::ContentType.new('application/octet-stream; slash="\\\\\\\\"')
    @content_type.params['slash'].should eql('\\\\')
  end

  it "should unquote quoted values containing semicolons" do
    @content_type = SMail::MIME::ContentType.new('application/octet-stream; semi="a;b"')
    @content_type.params['semi'].should eql('a;b')
  end

  it "should ignore trailing whitespace from an unquoted value" do
    @content_type = SMail::MIME::ContentType.new('MULTIPART/MIXED; boundary=owatagusiam ')
    @content_type.params['boundary'].should eql('owatagusiam')
    @content_type.params.length.should eql(1)
  end

  it "should ignore trailing whitespace from a quoted value" do
    @content_type = SMail::MIME::ContentType.new('MULTIPART/MIXED; boundary="owatagusiam" ')
    @content_type.params['boundary'].should eql('owatagusiam')
    @content_type.params.length.should eql(1)
  end

  it "should combine continued values as specified sections 3 and 5 of RFC2231 to one string" do
    @content_type = SMail::MIME::ContentType.new('image/jpeg; a*0=a; a*1=b')
    @content_type.params['a'].should eql('ab')
  end

  it "should decode a param with a charset" do
    @ct = SMail::MIME::ContentType.new('type/t; a*=ISO-8859-1\'\'This%20is%20a%20test')
    @ct.params['a'].should eql('This is a test')
  end

  it "should decode a param with a charset and a continuation" do
    @ct = SMail::MIME::ContentType.new('type/t; a*0*=ISO-8859-1\'\'This%20is; a*1*=%20a%20test')
    @ct.params['a'].should eql('This is a test')
  end

  it "should decode a param using RFC2047 field encoding (Becky!)" do
    @content_type = SMail::MIME::ContentType.new('type/t; a="=?US-ASCII?q?This_is_a_test?=')
    @content_type.params['a'].should eql('This is a test')
  end

end

