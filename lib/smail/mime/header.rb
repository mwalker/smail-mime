require 'strscan'

class SMail #:nodoc:
  class MIME < SMail

    PATTERN_RFC2047_FIELD = '(.*?)(=\?(?:[^?]+)\?(?:.)\?(?:[^?]*)\?=)(.*)'

    class << self
      # Parses a Content-* header and returns the bits.
      #
      # Given the contents of a header field such as
      #
      #   text/plain; charset=US-ASCII
      #
      # this will return:
      #
      #   [ 'text', 'plain', { 'charset' => 'US-ASCII' } ]
      #
      # The type and the keys of the hash are all converted to lower case.
      #
      # This parses Content-Type and Content-Disposition headers according to
      # the description of the Content-Type header in section 5.1 of RFC2045.
      #
      # It also handles continuations and character sets in parameter values
      # as described in sections 3 and 4 of RFC2231.
      def decode_content_field(text)
        s = StringScanner.new(text)

        type = s.scan(/[^;]*/)
        s.skip(/;\s*/)

        params   = {}
        charsets = {}
        while key = s.scan(/[^=]+/)
          s.skip(/=/)
          if s.skip(/"/)
            # Deal with quoted parameters.
            value = s.scan(/(\\.|[^"])*/)
            s.skip(/"/)
            value.gsub!(/\\(.)/, '\1')
          else
            value = s.scan(/[^;\s]+/)
          end

          is_encoded = false
          if key =~ /^(.*)\*$/
            key = $1
            is_encoded = true
          end

          is_continued = false
          if key =~ /^(.*)\*[0-9]+$/
            key = $1
            is_continued = true
          end

          if is_encoded
            # Deal with character sets and languages.
            if value =~ /^([^']*)'([^']*)'(.*)$/
              charsets[key] = ($1 or 'US-ASCII')
              value = $3
            end
            value.gsub!(/%([[:xdigit:]]{2})/) { $1.hex.chr }
            value.iconv!(charsets[key], 'UTF-8')
          end

          if is_continued and params[key]
            # Deal with parameter continuations.
            params[key] << value
          else
            params[key] = value
          end

          s.skip(/\s*;?\s*/) # skip any whitespace before and after a semicolon
        end

        # Some mail clients (I'm looking at you Becky!) don't use RFC2231 parameter
        # value character set information but instead encode the parameters as
        # RFC2047 fields, so lets cycle through them and try to decode, this should
        # not do any harm if they don't have encoded fields
        params.each_key {|key|
          params[key] = self.decode_field(params[key])
        }

        [type, params]
      end

      # Decodes any RFC2047 words in a string and returns the string as UTF-8.
      # Uses our iconv to deal with common encoding problems
      def decode_field(text)
        return nil if text.nil?
        result = ''
        while text =~ Regexp.new(PATTERN_RFC2047_FIELD, Regexp::MULTILINE)
          prefix, encoded, text = $1, $2, $3
          result << prefix unless prefix =~ Regexp.new('\A\s*\Z', Regexp::MULTILINE)
          result << decode_word(encoded)
        end
        result << text
        result
      end

      # Decodes an RFC2047 word to a UTF-8 string.
      # Uses our iconv to deal with common encoding problems
      def decode_word(text)
        return text unless text =~ /=\?([^?]+)\?(.)\?([^?]*)\?=/
          
        charset, method, encoded_string = $1, $2, $3
          
        # Strip out the RFC2231 language specification if there is one.
        charset  = $1 if charset =~ /^([^\*]+)\*?(.*)$/
            
        # Quoted-printable in RFC2047 substitutes spaces with underscores.
        encoded_string.tr!('_', ' ') if method.downcase == 'q'
        
        encoded_string.decode_mime(method).iconv('utf-8', charset)
      end

      # Takes the given UTF-8 string, converts it the given character set, and
      # encodes it as an RFC2047 style field.
      #
      # All arguments after text are optional. If a method is not supplied,
      # the String.best_mime_encoding method is used to pick one. The charset
      # defaults to UTF-8, and the line length to 66 characters.
      def encode_field(text, method = nil, charset = 'UTF-8', line_length = 66)
        return '' if text.nil?
        method ||= text.best_mime_encoding
        method = method.downcase if method.kind_of?(String)
        case method
          when :none
            text
          when :base64, 'b', 'base64'
            encode_base64_field(text, charset, line_length)
          when :quoted_printable, 'q', 'quoted-printable'
            encode_quoted_printable_field(text, charset, line_length)
          else
            raise ArgumentError, "Bad MIME encoding"
        end
      end

      def encode_quoted_printable_field(text, charset = 'UTF-8', line_length = 66) #:nodoc:
        charset.upcase!
        encoded_line_length = line_length - (charset.length + 7)
  
        iconv        = Iconv.new(charset, 'UTF-8')
        encoded_text = ''
        word         = ''
        text.each_char do |char|
          char = iconv.iconv(char)
          # RFC2047 has its own ideas about quoted-printable encoding.
          char.encode_quoted_printable!
          char = case char
            when "_":  "=5F"
            when " ":  "_"
            when "?":  "=3F"
            when "\t": "=09"
            else char
          end
          if word.length + char.length > encoded_line_length
            encoded_text << "=?#{charset}?Q?#{word}?=\n "
            word = ''
          end
          word << char
        end
        encoded_text << "=?#{charset}?Q?#{word}?="
        encoded_text
      end

      def encode_base64_field(text, charset = 'UTF-8', line_length = 66) #:nodoc:
        charset.upcase!
        unencoded_line_length = (line_length - (charset.length + 7)) / 4 * 3
  
        iconv        = Iconv.new(charset, 'UTF-8')
        encoded_text = ''
        word         = ''
        text.each_char do |char|
          char = iconv.iconv(char)
          if word.length + char.length > unencoded_line_length
            encoded_text << "=?#{charset}?B?#{word.encode_base64.chomp}?=\n "
            word = ''
          end
          word << char
        end
        encoded_text << "=?#{charset}?B?#{word.encode_base64.chomp}?="
        encoded_text
      end

    end # self
  end
          
end
