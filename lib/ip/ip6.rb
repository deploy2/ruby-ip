class V6 < IP
    class << self; alias :new :orig_new; end
    PROTO = "v6".freeze
    PROTO_TO_CLASS[PROTO] = self
    ADDR_BITS = 128
    MASK = (1 << ADDR_BITS) - 1

    # Parse a string; return an V6 instance if it's a valid IPv6 address,
    # nil otherwise
    #--
    # FIXME: allow larger variations of mapped addrs like 0:0:0:0:ffff:1.2.3.4
    #++
    def self.parse(str)
      case str
      when /\A\[?::(ffff:)?(\d+\.\d+\.\d+\.\d+)\]?(?:\/(\d+))?(?:@(.*))?\z/i
        mapped = $1
        pfxlen = ($3 || 128).to_i
        ctx = $4
        return nil if pfxlen > 128
        v4 = (V4.parse($2) || return).to_i
        v4 |= 0xffff00000000 if mapped
        new(v4, pfxlen, ctx)
      when /\A\[?([0-9a-f:]+)\]?(?:\/(\d+))?(?:@(.*))?\z/i
        addr = $1
        pfxlen = ($2 || 128).to_i
        return nil if pfxlen > 128
        ctx = $3
        return nil if pfxlen > 128
        if addr =~ /\A(.*?)::(.*)\z/
          left, right = $1, $2
          l = left.split(':')
          r = right.split(':')
          rest = 8 - l.length - r.length
          return nil if rest < 0
        else
          l = addr.split(':')
          r = []
          rest = 0
          return nil if l.length != 8
        end
        out = ""
        l.each { |quad| return nil if quad.length>4; out << quad.rjust(4,"0") }
        rest.times { out << "0000" }
        r.each { |quad| return nil if quad.length>4; out << quad.rjust(4,"0") }
        new(out, pfxlen, ctx)
      else
        nil
      end
    end

    # Return just the address part as a String in compact decimal form
    def to_addr
      if ipv4_compat?
        "::#{native.to_addr}"
      elsif ipv4_mapped?
        "::ffff:#{native.to_addr}"
      elsif @addr.zero?
        "::"
      else
        res = to_hex.scan(/..../).join(':')
        res.gsub!(/\b0{1,3}/,'')
        res.sub!(/\b0:0:0:0(:0)*\b/,':') ||
          res.sub!(/\b0:0:0\b/,':') ||
          res.sub!(/\b0:0\b/,':')
        res.sub!(/:::+/,'::')
        res
      end
    end
    # Return just the address in non-compact form, required for reverse IP.
    def to_addr_full
      if ipv4_compat?
        "::#{native.to_addr}"
      elsif ipv4_mapped?
        "::ffff:#{native.to_addr}"
      elsif @addr.zero?
        "::"
      else
        return to_hex.scan(/..../).join(':')
      end
    end
    #return the arpa version of the address for reverse DNS: http://en.wikipedia.org/wiki/Reverse_DNS_lookup
    def to_arpa
      return self.to_addr_full.reverse.gsub(':','').split(//).join('.') + ".ip6.arpa"
    end

    def ipv4_mapped?
      (@addr >> 32) == 0xffff
    end
    
    def ipv4_compat?
      @addr > 1 && (@addr >> 32) == 0
    end
    
    # Convert an IPv6 mapped/compat address to a V4 native address
    def native
      return self unless (ipv4_mapped? || ipv4_compat?) && (@pfxlen >= 96)
      V4.new(@addr & V4::MASK, @pfxlen - 96, @ctx)
    end
  end