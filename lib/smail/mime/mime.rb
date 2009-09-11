class SMail
  class MIME < SMail
    class << self
    end

    attr_accessor :parts, :preamble, :epilogue
    attr_reader :content_type, :boundary

    def initialize(text = '')
      super(text)
      self.content_type = self.header('content-type')
      fill_parts
    end

    # Returns the size of the message in bytes.
    def size
      self.to_s.length
    end

    # Sets the content type
    def content_type=(content_type)
      case content_type
        when SMail::MIME::ContentType
          @content_type = content_type
        when String
          self.content_type = SMail::MIME::ContentType.new(content_type)
        when nil
          self.content_type = SMail::MIME::ContentType.new
        else
          raise ArgumentError
      end
    end

    # Is this a multipart message
    def multipart?
      @content_type.composite?
    end

    # Returns the MIME-Version as a string (unlikely to be anything but '1.0')
    def version
      self.header('mime-version') || '1.0'
    end

    # Returns the subject in UTF-8
    def subject
      SMail::MIME.decode_field(subject_raw)
    end

    # Sets the subject, performs any necessary encoding
    def subject=(text)
      self.subject_raw = SMail::MIME.encode_field(text)
    end

    # Returns the raw potentially MIME encoded subject
    def subject_raw
      self.header('subject')
    end

    # Set the subject directly, any necessary MIME encoding is up to the caller
    def subject_raw=(text)
      self.header_set('subject', text)
    end

    # Returns the date from the Date header as a DateTime object.
    def date
      date = self.header('date')
      return nil unless date
      SMail::MIME::Date.parse(date)
      #(year, month, day, hour, minute, second, timezone, weekday) = ParseDate.parsedate(date)
      #Time.gm(second, minute, hour, day, month, year, weekday, nil, nil, timezone)
    end


    # Returns the raw body of the email including all parts
    alias body_raw body

    # Returns the body decoded and converted to UTF-8 if necessary, if this is is a 
    # multipart message this is not what you suspect
    def body
      if self.multipart? # what if it is message/rfc822 ?
        @preamble 
      else
        # decode
        case self.header('content-transfer-encoding')
          when 'quoted-printable'
            body = @body.decode_quoted_printable
          when 'base64'
            body = @body.decode_base64
          else
            # matches nil when there is no header or an unrecognised encoding
            body = @body
        end
        
        # convert to UTF-8 if text
        if self.content_type.media_type == 'text'
          charset = self.content_type.params['charset'] || 'us-ascii'
          body.iconv!('utf-8', charset)
        end

        body
      end
    end

    # Returns a string description of the MIME structure of this message.
    #
    # This is useful for debugging and testing. The returned string is
    # formatted as shown in the following example:
    #   multipart/mixed
    #     multipart/alternative
    #       text/plain
    #       multipart/related
    #         text/html
    #         image/gif
    #     application/octet-stream
    def describe_mime_structure(depth = 0)
      result = ('  '*depth) + self.content_type.type + "\n"
      if self.multipart?
        self.parts.each do |part|
          result << part.describe_mime_structure(depth+1)
        end
      end
      result.chomp! if depth == 0
      result
    end

    # Pulls out any body parts matching the given MIME types and puts them
    # into an array.
    #
    # This is useful for pulling out parts in the appropriate order for
    # rendering. For example calling:
    #   message.flatten_body('text/plain', /^application\/.*$)
    # should return all the text parts and attached files in the order in
    # which they appear in the original message.
    #
    # The various multipart subtypes are handled sensibly. For example,
    # for multipart/alternative messages, the best matching part (i.e. the
    # last part consisting entirely of the given types) is used.
    def flatten_body(*types)
      types = types.flatten
      if self.multipart?
        case self.content_type.type
          when 'multipart/alternative'
            part = self.parts.reverse.find {|part| part.consists_of_mime_types?(types) }
            part ? part.flatten_body(types) : []
          when 'multipart/mixed', 'multipart/related'
            # FIXME: For multipart/related, this should look for a start parameter and try that first.    
            parts = self.parts.collect {|part| part.flatten_body(types) }
            parts.flatten
          when 'multipart/signed'
            self.parts.first.flatten_body(types)
          when 'multipart/appledouble'
            self.parts[1].flatten_body(types)
          else
            # FIXME: should we also have an entry for message/rfc822 etc.
            []
        end
      else
        self.consists_of_mime_types?(types) ? [self] : []
      end
    end

    # Returns true if the message consists entirely of the given mime types.
    #
    # For single part messages this is simple: the Content-Type of the
    # message must by one of the supplied types.
    #
    # For multipart messages it gets a bit more complicated. We try to
    # make sure that the message can be entirely decomposed into
    # just the supplied types.
    #
    # The rules are as follows:
    # [multipart/alternative]
    #   At least one sub-part must consist of the given types. 
    # [multipart/mixed]
    #   All sub-parts must consist of the given types.
    # [multipart/related]
    #   The root part (usually the first part) must consist of the
    #   given types.
    # [multipart/signed]
    #   The first part must consist of the given types.
    # [multipart/appledouble]
    #   The second part must consist of the given types. (See RFC 1740.)
    def consists_of_mime_types?(*types)
      types = types.flatten
      type = self.content_type.type

      if self.multipart?
        case type
          when 'multipart/alternative'
            self.parts.any? {|part| part.consists_of_mime_types?(types) }
          when 'multipart/mixed'
            self.parts.all? {|part| part.consists_of_mime_types?(types) }
          when 'multipart/related'
            # FIXME: This should look for a start parameter and try that first.
            self.parts.first.consists_of_mime_types?(types)
          when 'multipart/signed'
            self.parts.first.consists_of_mime_types?(types)
          when 'multipart/appledouble'
            self.parts[1].consists_of_mime_types?(types)
          when 'message/rfc822', 'message/rfc2822'
            self.parts.first.consists_of_mime_types?(types)
          else
            false
        end
      else
        types.any? {|t| t === type }
      end
    end



private

    def fill_parts
      if self.content_type.discrete?
        parts_single_part
      else
        parts_multipart
      end
    end

    def parts_single_part
      @parts = []
    end

    def parts_multipart
      @parts = []
      @boundary = self.content_type.params['boundary']

      if self.content_type.type == 'message/rfc822' or self.content_type.type == 'message/rfc2822'
        @parts << SMail::MIME.new(@body)
        return @parts
      end

      return parts_single_part unless @boundary

      #alias body_raw body # FIXME: does this work?

      epilogue_re = Regexp.new("^--#{Regexp.escape(@boundary)}--\s*\r?$", Regexp::MULTILINE)
      (body, @epilogue) = @body.split(epilogue_re, 2)
      @epilogue.lstrip! unless @epilogue.nil?

      bits_re = Regexp.new("^--#{Regexp.escape(@boundary)}\s*\r?$", Regexp::MULTILINE)
      bits = body.split(bits_re)

      @preamble = bits.shift # FIXME is this OK? or better to see a header in the first line?

      bits.each do |bit|
        bit.lstrip!
        @parts << SMail::MIME.new(bit)
      end
        
      @parts
    end

  end
end
