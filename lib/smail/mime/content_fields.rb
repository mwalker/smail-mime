class SMail #:nodoc:
  class MIME < SMail
    class ContentField
      class << self
      end

      attr_accessor :type_raw # The raw type as parsed from the message.
      attr_reader :params

      def initialize(text = nil)
        @params = Params.new
        unless text.nil?
          (@type_raw, params_raw) = SMail::MIME.decode_content_field(text)
          @params.replace(params_raw)
        end
      end

      # Returns the type as a lower case string
      def type
        @type_raw.nil? ? @type_raw : @type_raw.downcase
      end

      def type=(text)
        @type_raw = text
      end

      # Returns the Content Field as a string suitable for inclusion in an email header.
      def to_s
        "#{@type_raw}#{self.params.to_s}"
      end

      class Params < Hash
        class << self
          # FIXME: These two should probably be moved
          def needs_quoting?(text)
            false # FIXME
          end

          def quote(text)
            "\"#{text}\"" # FIXME
          end
        end

        def to_s
          if self.empty?
            return ""
          else
            pairs = []
            self.each do |key, value|
              pair = key + '='
              if SMail::MIME::ContentField::Params.needs_quoting?(value)
                pair << SMail::MIME::ContentField::Params.quote(value)
              else
                pair << value
              end
              pairs << pair
            end
          end
          '; ' + pairs.join('; ')
        end
      end
    end # ContentField

    # An object representing a Content-Disposition header as specified in RFC2183.
    class ContentDisposition < ContentField

      # Is this an inline part??
      def inline?
        type == 'inline'
      end

      # Is this an attachment part?
      def attachment?
        type == "attachment"
      end

      # Returns the filename if specified
      def filename
        self.params['filename']
      end

      # Returns the creation date if available or nil.
      def creation_date
        self.params['creation-date'] # FIXME: parse as a date?
      end

      # Returns the modification date if available or nil.
      def modification_date
        self.params['modification-date'] # FIXME: parse as a date?
      end

      # Returns the read date if available or nil.
      def read_date
        self.params['read-date'] # FIXME: parse as a date?
      end

      # Returns the size if available or nil.
      def size
        self.params['size']
      end

      # FIXME: add all the other parameters specified in RFC2183, also add setters

      # Returns the Content-Disposition as a string suitable for inclusion in an email
      # header. If no disposition type is specified it will default to a disposition
      # type of 'attachment'.
      def to_s
        "#{self.type_raw || 'attachment'}#{self.params.to_s}"
      end

    end # ContentDisposition

    class ContentType < ContentField

      attr_accessor :media_type_raw, :media_subtype_raw

      def initialize(text = nil)
        super(text)
        self.type = @type_raw
      end

      # Returns the media type
      def media_type
        @media_type_raw.nil? ? @media_type_raw : @media_type_raw.downcase
      end

      # Set the media type
      def media_type=(text)
        @media_type_raw = text
      end

      # Returns the media subtype
      def media_subtype
        @media_subtype.nil? ? @media_subtype_raw : @media_subtype_raw.downcase
      end

      # Set the media subtype
      def media_subtype=(text)
        @media_subtype_raw = text
      end

      # Returns the media 'type/subtype' as a lower case string.
      def type
        # Default to 'text/plain'
        if @media_type_raw.nil? or @media_subtype_raw.nil?
          'text/plain'
        else
          "#{@media_type_raw}/#{@media_subtype_raw}".downcase
        end
      end

      # Set the media 'type/subtype' together
      def type=(text = nil)
        unless text.nil?
          @type_raw = text # keep this inherited accessor in sync
          (@media_type_raw, @media_subtype_raw) = text.split('/', 2)
        end
      end

      # Is this a composite media type as specified in section 5.1 of RFC 2045.
      #
      # Note extension tokens are permitted to be composite but will always be seen
      # as discrete by this code.
      def composite?
        media_type == 'message' or media_type == 'multipart'
      end

      # Is this a discrete media type as specified in section 5.1 of RFC 2045.
      #
      # Note extension tokens are permitted to be composite but will always be seen
      # as discrete by this code.
      def discrete?
        !composite?
      end

      # Returns the full Content-Type header as a string suitable for inclusion in an
      # email header. If either of the media type or subtype are not specified it will
      # default to 'text/plain; charset=us-ascii'.
      def to_s
        # Default to 'text/plain; charset=us-ascii'
        if @media_type_raw.nil? or @media_subtype_raw.nil?
          'text/plain; charset=us-ascii'
        else
          "#{@media_type_raw}/#{@media_subtype_raw}#{self.params.to_s}"
        end
      end
    end # ContentType
  end
end
