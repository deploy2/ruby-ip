# Copyright (C) 2009-2010 Brian Candler <http://www.deploy2.net/>
# Licensed under the same terms as ruby. See LICENCE.txt and COPYING.txt

class IP
  PROTO_TO_CLASS = {}

  class << self
    alias :orig_new :new
    # Examples:
    #   IP.new("1.2.3.4")
    #   IP.new("1.2.3.4/28")
    #   IP.new("1.2.3.4/28@routing_context")
    #
    # Array form (inverse of to_a and to_ah):
    #   IP.new(["v4", 0x01020304])
    #   IP.new(["v4", 0x01020304, 28])
    #   IP.new(["v4", 0x01020304, 28, "routing_context"])
    #   IP.new(["v4", "01020304", 28, "routing_context"])
    #
    # Note that this returns an instance of IP::V4 or IP::V6. IP is the
    # base class of both of those, but cannot be instantiated itself.
    def new(src)
      case src
      when String
        parse(src) || (raise ArgumentError, "invalid address")
      when Array
        (PROTO_TO_CLASS[src[0]] || (raise ArgumentError, "invalid protocol")).new(*src[1..-1])
      when IP
        src.dup
      else
        raise ArgumentError, "invalid address"
      end
    end
    
    # Parse a string as an IP address - return a V4/V6 object or nil
    def parse(str)
      V4.parse(str) || V6.parse(str)
    end
  end
    
  # Length of prefix (network portion) of address
  attr_reader :pfxlen

  # Routing Context indicates the scope of this address (e.g. virtual router)
  attr_accessor :ctx

  # Examples:
  #   IP::V4.new(0x01020304)
  #   IP::V4.new("01020304")
  #   IP::V4.new(0x01020304, 28)
  #   IP::V4.new(0x01020304, 28, "routing_context")
  def initialize(addr, pfxlen=nil, ctx=nil)
    @addr = addr.is_a?(String) ? addr.to_i(16) : addr.to_i
    raise ArgumentError, "Invalid address value" if @addr < 0 || @addr > self.class::MASK
    self.pfxlen = pfxlen
    self.ctx = ctx
  end

  # Return the protocol in string form, "v4" or "v6"  
  def proto
    self.class::PROTO
  end

  # Return the string representation of the address, x.x.x.x[/pfxlen][@ctx]
  def to_s
    ctx ? "#{to_addrlen}@#{ctx}" : to_addrlen
  end

  # Return the string representation of the IP address and prefix, or
  # just the IP address if it's a single address
  def to_addrlen
    pfxlen == self.class::ADDR_BITS ? to_addr : "#{to_addr}/#{pfxlen}"
  end

  # Return the address as an Integer
  def to_i
    @addr
  end

  # Return the address as a hexadecimal string (8 or 32 digits)
  def to_hex
    @addr.to_s(16).rjust(self.class::ADDR_BITS>>2,"0")
  end

  # Return an array representation of the address, with 3 or 4 elements
  # depending on whether there is a routing context set.
  #    ["v4", 16909060, 28]
  #    ["v4", 16909060, 28, "context"]
  # (Removing the last element makes them Comparable, as nil.<=> doesn't exist)
  def to_a
    @ctx ? [self.class::PROTO, @addr, @pfxlen, @ctx] :
           [self.class::PROTO, @addr, @pfxlen]
  end

  # Return an array representation of the address, with 3 or 4 elements
  # depending on whether there is a routing context set, using hexadecimal.  
  #    ["v4", "01020304", 28]
  #    ["v4", "01020304", 28, "context"]
  def to_ah
    @ctx ? [self.class::PROTO, to_hex, @pfxlen, @ctx] :
           [self.class::PROTO, to_hex, @pfxlen]
  end

  # Change the prefix length. If nil, the maximum is used (32 or 128)  
  def pfxlen=(pfxlen)
    @mask = nil
    if pfxlen
      pfxlen = pfxlen.to_i
      raise ArgumentError, "Invalid prefix length" if pfxlen < 0 || pfxlen > self.class::ADDR_BITS
      @pfxlen = pfxlen
    else
      @pfxlen = self.class::ADDR_BITS
    end
  end

  # Return the mask for this pfxlen as an integer. For example,
  # a V4 /24 address has a mask of 255 (0x000000ff)
  def mask
    @mask ||= (1 << (self.class::ADDR_BITS - @pfxlen)) - 1
  end

  # Return a new IP object at the base of the subnet, with an optional
  # offset applied.
  #    IP.new("1.2.3.4/24").network    =>  #<IP::V4 1.2.3.0/24>
  #    IP.new("1.2.3.4/24").network(7) =>  #<IP::V4 1.2.3.7/24>
  def network(offset=0)
    self.class.new((@addr & ~mask) + offset, @pfxlen, @ctx)
  end

  # Return a new IP object at the top of the subnet, with an optional
  # offset applied.  
  #    IP.new("1.2.3.4/24").broadcast     =>  #<IP::V4 1.2.3.255/24>
  #    IP.new("1.2.3.4/24").broadcast(-1) =>  #<IP::V4 1.2.3.254/24>
  def broadcast(offset=0)
    self.class.new((@addr | mask) + offset, @pfxlen, @ctx)
  end

  # Return a new IP object representing the netmask
  #    IP.new("1.2.3.4/24").netmask  =>  #<IP::V4 255.255.255.0>
  def netmask
    self.class.new(self.class::MASK & ~mask)
  end
  
  # Return a new IP object representing the wildmask (inverse netmask)
  #    IP.new("1.2.3.4/24").netmask  =>  #<IP::V4 0.0.0.255>
  def wildmask
    self.class.new(mask)
  end
  
  # Masks the address such that it is the base of the subnet
  #    IP.new("1.2.3.4/24").mask!    => #<IP::V4 1.2.3.0/24>
  def mask!
    @addr &= ~mask
    self
  end

  # Returns true if this is not the base address of the subnet implied
  # from the prefix length (e.g. 1.2.3.4/24 is offset, because the base
  # is 1.2.3.0/24)
  def offset?
    @addr != (@addr & ~mask)
  end
  
  # Returns offset from base of subnet to this address
  #    IP.new("1.2.3.4/24").offset   => 4
  def offset
    @addr - (@addr & ~mask)
  end

  # If the address is not on the base, turn it into a single IP.
  #    IP.new("1.2.3.4/24").reset_pfxlen!  =>  <IP::V4 1.2.3.4>
  #    IP.new("1.2.3.0/24").reset_pfxlen!  =>  <IP::V4 1.2.3.0/24>
  def reset_pfxlen!
    self.pfxlen = nil if offset?
    self
  end
  
  def to_range
    a1 = @addr & ~mask
    a2 = a1 | mask
    (a1..a2)
  end

  # The number of IP addresses in subnet
  #    IP.new("1.2.3.4/24").size   => 256
  def size
    mask + 1
  end

  def +(other)
    self.class.new(@addr + other.to_int, @pfxlen, @ctx)
  end

  def -(other)
    self.class.new(@addr - other.to_int, @pfxlen, @ctx)
  end

  def &(other)
    self.class.new(@addr & other.to_int, @pfxlen, @ctx)
  end

  def |(other)
    self.class.new(@addr | other.to_int, @pfxlen, @ctx)
  end

  def ^(other)
    self.class.new(@addr ^ other.to_int, @pfxlen, @ctx)
  end

  def ~
    self.class.new(~@addr & self.class::MASK, @pfxlen, @ctx)
  end

  def succ!
    @addr += 1
    self
  end

  def inspect
    res = "#<#{self.class} #{to_s}>"
  end

  def ipv4_mapped?
    false
  end

  def ipv4_compat?
    false
  end

  def native
    self
  end

  def hash
    to_a.hash
  end

  def eql?(other)
    to_a.eql?(other.to_a)
  end

  def <=>(other)
    to_a <=> other.to_a
  end
  include Comparable

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
  end
  
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
      else
        res = to_hex.scan(/..../).join(':')
        res.gsub!(/\b0{1,3}/,'')
        res.gsub!(/(\A|:)(0:)+/,'::')
        res.gsub!(/::0\z/, '::')
        res
      end
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
end
