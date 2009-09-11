#require 'jcode'
require 'iconv'

# Extensions to the String library for encoding and decoding of MIME data.
class String

  # Returns true if the string consists entirely of whitespace.
  # (The empty string will return false.)
  def is_space?
    return Regexp.new('\A\s+\Z', Regexp::MULTILINE).match(self) != nil
  end

  # Returns true if the string contains only valid ASCII characters
  # (i.e. nothing over ASCII 127).
  def is_ascii?
      self.length == self.tr("\200-\377", '').length
  end
    
  # Returns this string encoded as base64 as defined in RFC2045, section 6.8.
  def encode_base64
    [self].pack("m*")
  end

  # Performs encode_base64 in place, and returns the string.
  def encode_base64!
    self.replace(self.encode_base64)
  end
  
  # Returns this string decoded from base64 as defined in RFC2045, section 6.8.
  def decode_base64
    #self.unpack("m*").first
    # This should be the above line but due to a bug in the ruby base64 decoder
    # it will only decode base64 where the lines are in multiples of 4, this is
    # contrary to RFC2045 which says that all characters other than the 65 used
    # are to be ignored. Currently we remove all the other characters but it 
    # might be better to use it's advice to only remove line breaks and white
    # space
    self.tr("^A-Za-z0-9+/=", "").unpack("m*").first
  end

  # Performs decode_base64 in place, and returns the string.
  def decode_base64!
    self.replace(self.decode_base64)
  end

  # Returns this string encoded as quoted-printable as defined in RFC2045, section 6.7.
  def encode_quoted_printable
    result = [self].pack("M*")
    # Ruby's quoted printable encoding uses soft line breaks to buffer spaces
    # at the end of lines, rather than encoding them with =20. We fix this.
    result.gsub!(/( +)=\n\n/) { "=20" * $1.length + "\n" }
    # Ruby's quoted printable encode puts a soft line break on the end of any
    # string that doesn't already end in a hard line break, so we have to
    # clean it up.
    result.gsub!(/=\n\Z/, '')
    result
  end

  # Performs encode_quoted_printable in place, and returns the string.
  def encode_quoted_printable!
    self.replace(self.encode_quoted_printable)
  end
  
  # Returns this string decoded from quoted-printable as defined in RFC2045, section 6.7.
  def decode_quoted_printable
    self.unpack("M*").first
  end
  
  # Performs decode_quoted_printable in place, and returns the string.
  def decode_quoted_printable!
    self.replace(self.decode_quoted_printable)
  end
  
  # Guesses whether this string is encoded in base64 or quoted-printable.
  #
  # Returns either :base64 or :quoted_printable
  def guess_mime_encoding
    # Grab the first line and have a guess?
    # A multiple of 4 and no characters that aren't in base64 ?
    # Need to allow for = at end of base64 string
    squashed = self.tr("\r\n\s", '').strip.sub(/=*\Z/, '')
    if squashed.length.remainder(4) == 0 && squashed.count("^A-Za-z0-9+/") == 0
        :base64
    else
        :quoted_printable
    end
    # or should we just try both and see what works?
  end
  
  # Returns the MIME encoding that is likely to produce the shortest
  # encoded string, either :none, :base64, or :quoted_printable.
  def best_mime_encoding
    if self.is_ascii?
      :none
    elsif self.length > (self.mb_chars.length * 1.1)
      :base64
    else
      :quoted_printable
    end
  end
  
  # Decodes this string according to method, where method is
  # :base64, :quoted_printable, or :none.
  #
  # If method is not supplied or is nil, guess_mime_encoding is used to
  # try to pick an appropriate method.
  #
  # Method can also be a string: 'q', 'quoted-printable', 'b', or 'base64'
  # This lets you pass in methods directly from Content-Transfer-Encoding
  # headers, or from RFC2047 words. Matching is case-insensitive.
  def decode_mime(method = nil)
    method ||= guess_mime_encoding
    method = method.downcase if method.kind_of?(String)
    case method
      when :none
        self
      when :base64, 'b', 'base64'
        self.decode_base64
      when :quoted_printable, 'q', 'quoted-printable'
        self.decode_quoted_printable
      else
        raise ArgumentError, "Bad MIME encoding"
    end
  end
  
  # Performs decode_mime in place, and returns the string.
  def decode_mime!(method = nil)
    self.replace(self.decode_mime(method))
  end

  # Converts this string to to_charset from from_charset using Iconv.
  #
  # Because there are cases where charsets are encoded incorrectly on the 'net
  # we also allow for them and attempt to fix them up here. If conversion
  # ultimately fails we remove all characters 0x80 and above, replacing them
  # with ! symbols and effectively making it a US-ASCII (and therefore UTF-8)
  # string.
  def iconv(to_charset, from_charset)
    failed = false
    begin
      converted = Iconv.new(to_charset, from_charset).iconv(self)
    rescue Iconv::IllegalSequence
      case from_charset.downcase
        when 'us-ascii'
          # Some mailers do not send a charset when it should be CP1252,
          # the default Windows Latin charset
          begin
            converted = Iconv.new(to_charset, 'cp1252').iconv(self)
          rescue Iconv::IllegalSequence
            failed = true
          end
        when 'ks_c_5601-1987'
          # Microsoft products erroneously use this for what should be CP949
          # see http://tagunov.tripod.com/cjk.html
          begin
            converted = Iconv.new(to_charset, 'cp949').iconv(self)
          rescue Iconv::IllegalSequence, Iconv::InvalidCharacter
            failed = true
          end
        else
          failed = true
      end
    rescue Iconv::InvalidCharacter
      if self =~ /\n$/
        # Some messages can come in with a superfluous new line on the end,
        # which screws up the encoding. (ISO-2022-JP for example.)
        begin
          converted = Iconv.new(to_charset, 'iso-2022-jp').iconv(self.chomp) + "\n"
        rescue Iconv::InvalidCharacter
          converted = self.tr("\200-\377", "\041")
        end
      else
        converted = self.tr("\200-\377", "\041")
      end
    end

    if failed
      begin
        converted = Iconv.new(to_charset + '//IGNORE', from_charset).iconv(self)
      rescue Iconv::InvalidCharacter
        converted = self.tr("\200-\377", "\041")
      end
    end

    converted
  end

  def iconv!(to_charset, from_charset)
    self.replace(self.iconv(to_charset, from_charset))
  end

end
