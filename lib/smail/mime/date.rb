class SMail #:nodoc:
  class MIME < SMail
    # We inherit from DateTime in order to make its to_s method return an RFC2822
    # compliant date string.
    class Date < DateTime
      # Return an RFC2822 compliant date string suitable for use in the Date header.
      def to_s
        # This should meet RFC2822 requirements
        self.strftime('%a, %e %b %Y %H:%M:%S %z').gsub(/\s+/, ' ')
      end
    end
  end
end
