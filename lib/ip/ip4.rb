class V4 < IP
    class << self; alias :new :orig_new; end
    PROTO = "v4".freeze
    PROTO_TO_CLASS[PROTO] = self
    ADDR_BITS = 32
    MASK = (1 << ADDR_BITS) - 1

    # Parse a string; return an V4 instance if it's a valid IPv4 address,
    # nil otherwise
    def self.parse(str)
      if str =~ /\A(\d+)\.(\d+)\.(\d+)\.(\d+)(?:\/(\d+))?(?:@(.*))?\z/
        pfxlen = ($5 || ADDR_BITS).to_i
        return nil if pfxlen > 32
        addrs = [$1.to_i, $2.to_i, $3.to_i, $4.to_i]
        return nil if addrs.find { |n| n>255 }
        addr = (((((addrs[0] << 8) | addrs[1]) << 8) | addrs[2]) << 8) | addrs[3]
        new(addr, pfxlen, $6)
      end
    end

    # Return just the address part as a String in dotted decimal form
    def to_addr
      sprintf("%d.%d.%d.%d",
        (@addr>>24)&0xff, (@addr>>16)&0xff, (@addr>>8)&0xff, @addr&0xff)
    end
    #return the arpa version of the address for reverse DNS: http://en.wikipedia.org/wiki/Reverse_DNS_lookup
    def to_arpa
      sprintf("%d.%d.%d.%d.in-addr.arpa.",
        @addr&0xff, (@addr>>8)&0xff, (@addr>>16)&0xff,(@addr>>24)&0xff)
    end
  end