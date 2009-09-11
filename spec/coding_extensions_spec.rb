require File.dirname(__FILE__) + '/../lib/smail/mime'
require File.dirname(__FILE__) + '/spec_helper'

describe "String.is_space?" do

  it "should have an is_space? method" do
    " ".respond_to?('is_space?').should be_true
  end

  it "should see ' ' as a space" do
    " ".is_space?.should be_true
  end

  it "should see '\n' as a space" do
    "\n".is_space?.should be_true
  end

  it "should see '\r\n' as a space" do
    "\r\n".is_space?.should be_true
  end

  it "should see '\t\r\n' as a space" do
    "\t\r\n".is_space?.should be_true
  end

  it "should see ' \n' as a space" do
    " \n".is_space?.should be_true
  end

  it "should see ' \r\n' as a space" do
    " \r\n".is_space?.should be_true
  end

  it "should see ' \t\r\n' as a space" do
    " \t\r\n".is_space?.should be_true
  end

  it "should see '\n ' as a space" do
    "\n ".is_space?.should be_true
  end

  it "should see '\r\n ' as a space" do
    "\r\n ".is_space?.should be_true
  end

  it "should see '\t\r\n ' as a space" do
    "\t\r\n ".is_space?.should be_true
  end

  it "should see ' \n ' as a space" do
    " \n ".is_space?.should be_true
  end

  it "should see ' \r\n ' as a space" do
    " \r\n ".is_space?.should be_true
  end

  it "should see ' \t\r\n ' as a space" do
    " \t\r\n ".is_space?.should be_true
  end

  it "should see '  \t\t \r \n\n \n' as a space" do
    "  \t\t \r \n\n \n".is_space?.should be_true
  end

  it "should not see '' as a space" do
    "".is_space?.should be_false
  end

  it "should not see 'a' as a space" do
    "a".is_space?.should be_false
  end

  it "should not see ' a' as a space" do
    " a".is_space?.should be_false
  end

  it "should not see 'a ' as a space" do
    "a ".is_space?.should be_false
  end

  it "should not see 'a\n' as a space" do
    "a\n".is_space?.should be_false
  end

  it "should not see 'a\r\n' as a space" do
    "a\r\n".is_space?.should be_false
  end

  it "should not see 'a\t\r\n' as a space" do
    "a\t\r\n".is_space?.should be_false
  end

  it "should not see '\na' as a space" do
    "\na".is_space?.should be_false
  end

  it "should not see '\r\na' as a space" do
    "\r\na".is_space?.should be_false
  end

  it "should not see '\t\r\na' as a space" do
    "\t\r\na".is_space?.should be_false
  end

  it "should not see '\na' as a space" do
    "\na ".is_space?.should be_false
  end

  it "should not see '\r\na' as a space" do
    "\r\na ".is_space?.should be_false
  end

  it "should not see '\t\r\na' as a space" do
    "\t\r\na ".is_space?.should be_false
  end

  it "should not see '\n a' as a space" do
    "\n a".is_space?.should be_false
  end

  it "should not see '\r\n a' as a space" do
    "\r\n a".is_space?.should be_false
  end

  it "should not see '\t\r\n a' as a space" do
    "\t\r\n a".is_space?.should be_false
  end

  it "should not see 'a \ta\r a \na' as a space" do
    " a \ta\r a \na ".is_space?.should be_false
  end

end

describe "String.is_ascii?" do

  it "should have an in_ascii? method" do
    "".respond_to?('is_ascii?').should be_true
  end

  it "should see '' as ascii" do
    "".is_ascii?.should be_true
  end

  it "should see ' ' as ascii" do
    " ".is_ascii?.should be_true
  end

  it "should see 'abc' as ascii" do
    "abc".is_ascii?.should be_true
  end

  it "should see '\000' as ascii" do
    "\000".is_ascii?.should be_true
  end

  it "should see '\199' as ascii" do
    "\199".is_ascii?.should be_true
  end

  it "should not see '\200' as ascii" do
    !"\200".is_ascii?.should be_false
  end

  it "should not see '\377' as ascii" do
    !"\377".is_ascii?.should be_false
  end

end

describe "String.encode_quoted_printable" do
  
  it "should encode an empty string as an empty string" do
    "".encode_quoted_printable.should eql("")
  end

  it "should encode a single letter as a single letter" do
    "a".encode_quoted_printable.should eql("a")
  end

  it "should encode a line as a line" do
    "a\n".encode_quoted_printable.should eql("a\n")
  end

  it "should encode '=' as '=3D'" do
    "=".encode_quoted_printable.should eql("=3D")
  end

  it "should encode a two byte UTF-8 character" do
    "\303\264".encode_quoted_printable.should eql("=C3=B4")
  end

  it "should encode a three byte UTF-8 character" do
    "\342\210\206".encode_quoted_printable.should eql("=E2=88=86")
  end

end

# FIXME: ruby is broken and does not include the \r
# FIXME: improve the shoulds and callout why with reference to the RFC
describe "String.decode_quoted_printable" do
  
  it "should decode an empty string to an empty string" do
    "".decode_quoted_printable.should eql("")
  end

  it "should decode 'a=\n' to 'a'" do
    "a=\n".decode_quoted_printable.should eql("a")
  end

  it "should decode a line to a line" do
    "a\n".decode_quoted_printable.should eql("a\n")
  end

  it "should decode ' =\n' to ' '" do
    " =\n".decode_quoted_printable.should eql(" ")
  end

  it "should deal with a common error and decode 'a=' to 'a'" do
    "a=".decode_quoted_printable.should eql("a")
  end

end

describe "String.encode_quoted_printable!" do

  it "should encode_quoted_printable in place" do
    s = "="
    s.encode_quoted_printable!
    s.should eql("=3D")
  end

end

describe "String.decode_quoted_printable!" do

  it "should decode_quoted_printable in place" do
    s = "a=\n"
    s.decode_quoted_printable!
    s.should eql("a")
  end

end

describe "String.encode_base64" do
  
  it "should encode an empty string as an empty string" do
    "".encode_base64.should eql("")
  end

  it "should encode a single letter" do
    "a".encode_base64.should eql("YQ==\n")
  end

  it "should encode two letters" do
    "ab".encode_base64.should eql("YWI=\n")
  end

  it "should encode three letters" do
    "abc".encode_base64.should eql("YWJj\n")
  end

  it "should encode a three byte UTF-8 character" do
    "\342\210\206".encode_base64.should eql("4oiG\n")
  end

end

describe "String.decode_base64" do
  
  it "should decode an empty string to an empty string" do
    "".decode_base64.should eql("")
  end

  it "should decode 'YQ==' to 'a'" do
    "YQ==".decode_base64.should eql("a")
  end

  it "should decode 'YWI=' to 'ab'" do
    "YWI=".decode_base64.should eql("ab")
  end

  it "should decode 'YWJj' to 'abc'" do
    "YWJj".decode_base64.should eql("abc")
  end

  it "should decode a three byte UTF-8 character" do
    "4oiG".decode_base64.should eql("\342\210\206")
  end

  it "should ignore '\n' when decoding" do
    "YQ==\n".decode_base64.should eql("a")
  end

end

describe "String.encode_base64!" do

  it "should encode_base64 in place" do
    s = "a"
    s.encode_base64!
    s.should eql("YQ==\n")
  end

end

describe "String.decode_base64!" do

  it "should decode_base64 in place" do
    s = "YQ==\n"
    s.decode_base64!
    s.should eql("a")
  end

end

describe "String.guess_mime_encoding" do

  it "should guess '=3D' as quoted-printable" do
    "=3D".guess_mime_encoding.should eql(:quoted_printable)
  end
  
  # FIXME: better guessing required
  #it "should guess 'YQ==' as base64" do
  #  "YQ==".guess_mime_encoding.should eql(:base64)
  #end

end

describe "String.best_mime_encoding" do
  
  it "should return :none if the string is ascii" do
    "us-ascii".best_mime_encoding.should eql(:none)
  end

  it "should return :quoted_printable when that makes sense" do
    "Guten Abend Hürz".best_mime_encoding.should eql(:quoted_printable)
  end

  it "should return :base64 when that makes sense" do
    "テストテスト送信テスト送信送信\n".best_mime_encoding.should eql(:base64)
  end

end

describe "String.decode_mime" do
  
  it "should decode quoted-printable when passed 'q' as the method" do
    "method=3Dq".decode_mime('q').should eql('method=q')
  end
  
  it "should decode quoted-printable when passed 'Q' as the method" do
    "method=3DQ".decode_mime('Q').should eql('method=Q')
  end
  
  it "should decode quoted-printable when passed 'quoted-printable' as the method" do
    "method=3Dqp".decode_mime('quoted-printable').should eql('method=qp')
  end

  it "should decode quoted-printable when passed :quoted_printable as the method" do
    "method=3D:qp".decode_mime(:quoted_printable).should eql('method=:qp')
  end

  it "should decode base64 when passed 'b' as the method" do
    "bWV0aG9k".decode_mime('b').should eql('method')
  end

  it "should decode base64 when passed 'B' as the method" do
    "TUVUSE9E".decode_mime('B').should eql('METHOD')
  end

  it "should decode base64 when passed 'base64' as the method" do
    "bG9uZw==".decode_mime('base64').should eql('long')
  end

  it "should decode base64 when passed :base64 as the method" do
    "c3ltYm9s".decode_mime(:base64).should eql('symbol')
  end

  it "should do nothing when passed :none" do
    "none".decode_mime(:none).should eql('none')
  end

  it "should raise an ArgumentError when passed an invalid mime encoding" do
    lambda{"".decode_mime('invalid')}.should raise_error(ArgumentError, 'Bad MIME encoding')
  end

end

describe "String.decode_mime!" do
  
  it "should decode quoted-printable in place" do
    s = 'decode=3D!'
    s.decode_mime!('Q')
    s.should eql('decode=!')
  end

  it "should decode base64 in place" do
    s = "ZGVjb2RlIQ=="
    s.decode_mime!('B')
    s.should eql('decode!')
  end

end
  
describe "String.iconv" do
  
  it "should convert us-ascii to utf-8 with no changes" do
    'us-ascii'.iconv('utf-8', 'us-ascii').should eql('us-ascii')
  end

  it "should replace invalid utf-8 characters with !" do
    "H\374rz".iconv('utf-8', 'utf-8').should eql('H!rz')
  end

  it "should try converting from cp1252 if converting from us-ascii fails" do
    "H\374rz".iconv('utf-8', 'us-ascii').should eql("Hürz")
  end

  it "should try converting from cp949 if converting from ks_c_5601-1987 fails" do
    "sOjI8cGk".decode_mime.iconv('utf-8', 'ks_c_5601-1987').should eql("계희정")
  end

  it "should deal with errant newlines on the end of iso-2022-jp encodings" do
    "\e$B%F%9%HAw?.\n".iconv('utf-8', 'iso-2022-jp').should eql("テスト送信\n")
  end

end
