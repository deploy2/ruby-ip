require 'test_helper'
require 'ip/base'

class IPTest < Test::Unit::TestCase
  context "v4" do
    should "build from string" do
      res = IP.new("1.2.3.4/26")
      assert_equal IP::V4, res.class
      assert_equal "1.2.3.4/26", res.to_s
      assert_equal "1.2.3.4/26", res.to_addrlen
      assert_equal 0x01020304, res.to_i
      assert_equal 1000000100000001100000100, res.to_b
      assert_equal 26, res.pfxlen
      assert_nil res.ctx
    end
    
    should "build from string with ctx" do
      res = IP.new("1.2.3.4/26@nat")
      assert_equal IP::V4, res.class
      assert_equal "1.2.3.4/26@nat", res.to_s
      assert_equal "1.2.3.4/26", res.to_addrlen
      assert_equal 0x01020304, res.to_i
      assert_equal 26, res.pfxlen
      assert_equal "nat", res.ctx
    end

    should "build from array" do
      res = IP.new(["v4", 0x01020304])
      assert_equal IP::V4, res.class
      assert_equal "1.2.3.4", res.to_s
      assert_equal 32, res.pfxlen
    end
    
    should "build from array with pfxlen" do
      res = IP.new(["v4", 0x01020304, 26])
      assert_equal IP::V4, res.class
      assert_equal "1.2.3.4/26", res.to_s
    end
    
    should "build from array with pfxlen and ctx" do
      res = IP.new(["v4", 0x01020304, 26, "bar"])
      assert_equal IP::V4, res.class
      assert_equal "1.2.3.4/26@bar", res.to_s
    end
    
    should "build from array with hex, pfxlen and ctx" do
      res = IP.new(["v4", "01020304", 26, "bar"])
      assert_equal IP::V4, res.class
      assert_equal "1.2.3.4/26@bar", res.to_s
    end
    
    should "build direct from integer" do
      res = IP::V4.new(0x01020304)
      assert_equal "1.2.3.4", res.to_s
      assert_equal 32, res.pfxlen
      assert_nil res.ctx
    end
    
    should "build direct from integer, pfxlen, ctx" do
      res = IP::V4.new(0x01020304, 24, "foo")
      assert_equal "1.2.3.4/24@foo", res.to_s
    end
    
    should "build from another IP" do
      s1 = IP.new("1.2.3.4/24@foo")
      s2 = IP.new(s1)
      assert_equal s1, s2
      assert_not_equal s1.object_id, s2.object_id
    end

    should "disallow invalid addr" do
      assert_raises(ArgumentError) { IP::V4.new(1 << 32) }
      assert_raises(ArgumentError) { IP::V4.new(-1) }
    end
    
    should "disallow invalid pfxlen" do
      assert_raises(ArgumentError) { IP.new("1.2.3.4/33") }
    end

    context "ip math" do
      setup do
        @addr1 = IP.new("1.2.3.4/24@foo")
        @addr2 = IP.new("1.2.3.5/24@foo")
      end

      should "add to ip address" do
        assert_equal @addr2, (@addr1 + 1)
      end

      should "subtract from ip address" do
        assert_equal @addr1, (@addr2 - 1)
      end
    end

    context "address not on subnet boundary" do
      setup do
        @addr = IP.new("1.2.3.4/24@foo")
      end

      should "have to_s" do
        assert_equal "1.2.3.4/24@foo", @addr.to_s
      end
      
      should "have to_addrlen" do
        assert_equal "1.2.3.4/24", @addr.to_addrlen
      end
      
      should "have to_addr" do
        assert_equal "1.2.3.4", @addr.to_addr
      end
      
      should "have to_arpa" do
        assert_equal "4.3.2.1.in-addr.arpa.", @addr.to_arpa
      end

      should "have to_i" do
        assert_equal 0x01020304, @addr.to_i
      end
      
      should "have to_a" do
        assert_equal ["v4", 0x01020304, 24, "foo"], @addr.to_a
      end
      
      should "have to_ah" do
        assert_equal ["v4", "01020304", 24, "foo"], @addr.to_ah
      end
      
      should "have to_hex" do
        assert_equal "01020304", @addr.to_hex
      end
      
      should "have inspect" do
        assert_equal "#<IP::V4 1.2.3.4/24@foo>", @addr.inspect
      end
      
      should "have pfxlen" do
        assert_equal 24, @addr.pfxlen
      end
      
      should "have proto" do
        assert_equal "v4", @addr.proto
      end
      
      should "have to_irange" do
        assert_equal((0x01020300 .. 0x010203ff), @addr.to_irange)
      end
      
      should "have to_range" do
        assert_equal IP.new("1.2.3.0@foo")..IP.new("1.2.3.255@foo"), @addr.to_range
      end

      should "have is_in?" do
        assert_equal IP.new("1.2.3.0/25").is_in?(IP.new("1.2.3.0/24")), true
      end
      
      should "find whether an IP is included in a range" do
        assert_equal IP.new("1.2.3.1").is_in?(IP.new("1.2.3.0/24")), true
      end
      
      should "find whether an IP is not included a range" do
        assert_equal IP.new("1.2.4.1").is_in?(IP.new("1.2.3.0/24")), false
      end
      
      should "find when a subnet is included in a range" do
        assert_equal IP.new("1.2.3.0/30").is_in?(IP.new("1.2.3.0/24")), true
      end

      should "find when a subnet is not included in a range" do
        assert_equal IP.new("1.2.4.0/30").is_in?(IP.new("1.2.3.0/24")), false
      end

      should "have split" do
        assert_equal IP.new("1.2.3.0/24").split, [IP.new("1.2.3.0/25"), IP.new("1.2.3.128/25")]
      end

      should "have divide_by_subnets be exact" do
        assert_equal IP.new("1.2.3.0/24").divide_by_subnets(4), [IP.new("1.2.3.0/26"), IP.new("1.2.3.64/26"),IP.new("1.2.3.128/26"), IP.new("1.2.3.192/26")]
      end

      should "have divide_by_subnets choose next largest" do
        assert_equal IP.new("1.2.3.0/24").divide_by_subnets(3), [IP.new("1.2.3.0/26"), IP.new("1.2.3.64/26"),IP.new("1.2.3.128/26"), IP.new("1.2.3.192/26")]
      end
      should "have divide_by_hosts subnet boundary" do
        assert_equal IP.new("1.2.3.0/24").divide_by_hosts(128), [IP.new("1.2.3.0/24")]
      end
      should "have divide_by_hosts full subnet" do
        assert_equal IP.new("1.2.3.0/24").divide_by_hosts(126), [IP.new("1.2.3.0/25"), IP.new("1.2.3.128/25")]
      end
      should "have divide_by_hosts partial subnet" do
        assert_equal IP.new("1.2.3.0/24").divide_by_hosts(68), [IP.new("1.2.3.0/25"), IP.new("1.2.3.128/25")]
      end
      
      should "have size" do
        assert_equal 256, @addr.size
      end
      
      should "have ctx reader" do
        assert_equal "foo", @addr.ctx
      end
      
      should "have ctx writer" do
        @addr.ctx = "bar"
        assert_equal "bar", @addr.ctx
      end

      should "have network" do
        assert_equal "1.2.3.0/24@foo", @addr.network.to_s
        assert_equal "1.2.3.9/24@foo", @addr.network(9).to_s
      end
      
      should "have broadcast" do
        assert_equal "1.2.3.255/24@foo", @addr.broadcast.to_s
        assert_equal "1.2.3.252/24@foo", @addr.broadcast(-3).to_s
      end
      
      should "have mask" do
        assert_equal 0x000000ff, @addr.mask
      end
      
      should "have netmask" do
        assert_equal "255.255.255.0", @addr.netmask.to_s
      end
      
      should "have wildmask" do
        assert_equal "0.0.0.255", @addr.wildmask.to_s
      end
      
      should "perform mask!" do
        res = @addr.mask!
        assert_equal "1.2.3.0/24@foo", res.to_s
        assert_equal "1.2.3.0/24@foo", @addr.to_s  # mutates object
      end
      
      should "have offset" do
        assert @addr.offset?
        assert_equal 4, @addr.offset
        @addr.reset_pfxlen!
        assert_equal "1.2.3.4@foo", @addr.to_s
      end

      should "have +" do
        assert_equal ["v4", 0x01020309, 24, "foo"], (@addr + 5).to_a
        assert_equal ["v4", 0x01020304, 24, "foo"], @addr.to_a
      end

      should "have -" do
        assert_equal ["v4", 0x010202ff, 24, "foo"], (@addr - 5).to_a
        assert_equal ["v4", 0x01020304, 24, "foo"], @addr.to_a
      end

      should "have &" do
        assert_equal ["v4", 0x00000304, 24, "foo"], (@addr & 0xffff).to_a
        assert_equal ["v4", 0x01020304, 24, "foo"], @addr.to_a
      end

      should "have |" do
        assert_equal ["v4", 0x01020307, 24, "foo"], (@addr | 7).to_a
        assert_equal ["v4", 0x01020304, 24, "foo"], @addr.to_a
      end

      should "have ^" do
        assert_equal ["v4", 0x010203fb, 24, "foo"], (@addr ^ 255).to_a
        assert_equal ["v4", 0x01020304, 24, "foo"], @addr.to_a
      end

      should "have ~" do
        assert_equal ["v4", 0xfefdfcfb, 24, "foo"], (~@addr).to_a
        assert_equal ["v4", 0x01020304, 24, "foo"], @addr.to_a
      end

      should "have pfxlen writer" do
        assert_equal 0xffffff00, @addr.netmask.to_i
        @addr.pfxlen = 29
        assert_equal 0xfffffff8, @addr.netmask.to_i
        assert_equal "1.2.3.4/29@foo", @addr.to_s
        assert_raises(ArgumentError) { @addr.pfxlen = 33 }
      end

      should "have native" do
        assert_equal @addr, @addr.native
      end
    end

    context "address on subnet boundary" do
      setup do
        @addr = IP.new("1.2.3.4/30")
      end
      
      should "have inspect" do
        assert_equal "#<IP::V4 1.2.3.4/30>", @addr.inspect
      end
      
      should "perform mask!" do
        @addr.mask!
        assert_equal "1.2.3.4/30", @addr.to_s
      end
      
      should "have offset" do
        assert !@addr.offset?
        assert_equal 0, @addr.offset
      end
    end

    context "single IP" do
      setup do
        @addr = IP.new("1.2.3.4")
      end
      
      should "have inspect" do
        assert_equal "#<IP::V4 1.2.3.4>", @addr.inspect
      end
      
      should "have pfxlen" do
        assert_equal 32, @addr.pfxlen
      end
      
      should "have size" do
        assert_equal 1, @addr.size
      end
      
      should "have offset" do
        assert !@addr.offset?
        assert_equal 0, @addr.offset
      end
    end
  end

  context "v6 normal" do
    should "build from string" do
      res = IP.new("dead:beef::123/48")
      assert_equal IP::V6, res.class
      assert_equal "dead:beef::123/48", res.to_s
      assert_equal "dead:beef::123/48", res.to_addrlen
      assert_equal 0xdeadbeef000000000000000000000123, res.to_i
      assert_equal 48, res.pfxlen
      assert_equal "v6", res.proto
      assert_nil res.ctx
    end
    
    should "build from string with ctx" do
      res = IP.new("dead:beef::123/48@nat")
      assert_equal IP::V6, res.class
      assert_equal "dead:beef::123/48@nat", res.to_s
      assert_equal "dead:beef::123/48", res.to_addrlen
      assert_equal 0xdeadbeef000000000000000000000123, res.to_i
      assert_equal 48, res.pfxlen
      assert_equal "nat", res.ctx
    end

    should "build from array" do
      res = IP.new(["v6", 0xdeadbeef000000000000000000000123])
      assert_equal IP::V6, res.class
      assert_equal "dead:beef::123", res.to_s
      assert_equal 128, res.pfxlen
      assert_nil res.ctx
    end
    
    should "build from array with pfxlen" do
      res = IP.new(["v6", 0xdeadbeef000000000000000000000123, 48])
      assert_equal IP::V6, res.class
      assert_equal "dead:beef::123/48", res.to_s
    end
    
    should "build from array with pfxlen and ctx" do
      res = IP.new(["v6", 0xdeadbeef000000000000000000000123, 48, "bar"])
      assert_equal IP::V6, res.class
      assert_equal "dead:beef::123/48@bar", res.to_s
    end
    
    should "build from array with hex, pfxlen and ctx" do
      res = IP.new(["v6", "deadbeef000000000000000000000123", 48, "bar"])
      assert_equal IP::V6, res.class
      assert_equal "dead:beef::123/48@bar", res.to_s
    end
    
    should "build direct from integer" do
      res = IP::V6.new(0xdeadbeef000000000000000000000123)
      assert_equal "dead:beef::123", res.to_s
      assert_equal 128, res.pfxlen
      assert_nil res.ctx
    end
    
    should "build direct from integer, pfxlen, ctx" do
      res = IP::V6.new(0xdeadbeef000000000000000000000123, 24, "foo")
      assert_equal "dead:beef::123/24@foo", res.to_s
      assert_equal 24, res.pfxlen
      assert_equal "foo", res.ctx
    end
    
    should "build from another IP" do
      s1 = IP.new("dead:beef::123/48@foo")
      s2 = IP.new(s1)
      assert_equal s1, s2
      assert_not_equal s1.object_id, s2.object_id
    end
    
    should "disallow invalid addr" do
      assert_raises(ArgumentError) { IP::V6.new(1 << 128) }
      assert_raises(ArgumentError) { IP::V6.new(-1) }
    end
    
    should "disallow invalid pfxlen" do
      assert_raises(ArgumentError) { IP.new("dead:beef::123/129@foo") }
    end
    
    should "have pfxlen writer" do
      res = IP::V6.new(0xdeadbeef000000000000000000000123, 24, "foo")
      res.pfxlen = 120
      assert_equal "dead:beef::123/120@foo", res.to_s
      assert_raises(ArgumentError) { res.pfxlen = 129 }
    end
    
    should "have native" do
      res = IP::V6.new(0xdeadbeef000000000000000000000123, 24, "foo")
      assert_equal res, res.native
    end
  end

  context "v6 ::0" do
    setup do
      @addr = IP::V6.new(0)
    end
    
    should "format" do
      assert_equal "::", @addr.to_s
    end

    should "have native" do
      assert_equal @addr, @addr.native
    end
  end
  
  context "v6 ::1" do
    setup do
      @addr = IP::V6.new(1)
    end
    
    should "format" do
      assert_equal "::1", @addr.to_s
    end

    should "have native" do
      assert_equal @addr, @addr.native
    end
  end
  
  context "v6 compat" do
    setup do
      @addr = IP.new("::1.2.3.4/120@xxx")
    end

    should "parse" do
      assert_equal 0x01020304, @addr.to_i
      assert_equal "xxx", @addr.ctx
    end

    should "format" do
      assert_equal "::1.2.3.4/120@xxx", @addr.to_s
    end

    should "have native" do
      a2 = @addr.native
      assert_equal "1.2.3.4/24@xxx", a2.to_s
    end
  end
  
  context "v6 mapped" do
    setup do
      @addr = IP.new("::ffff:1.2.3.4/120@xxx")
    end
    
    should "parse" do
      assert_equal 0xffff01020304, @addr.to_i
      assert_equal "xxx", @addr.ctx
    end
        
    should "format" do
      assert_equal "::ffff:1.2.3.4/120@xxx", @addr.to_s
    end

    should "have native" do
      a2 = @addr.native
      assert_equal "1.2.3.4/24@xxx", a2.to_s
    end
  end

  should "convert v6 addresses unambiguously" do
    assert_equal "1:0:2::", IP.new('1:0:2:0:0:0:0:0').to_s
    assert_equal "1::2:0", IP.new('1:0:0:0:0:0:2:0').to_s
  end
  
  context "comparing" do
    setup do
      @a1 = IP.new("1.2.3.4")
    end
    
    should "compare equal with same" do
      assert_equal @a1, IP.new("1.2.3.4")
    end
    
    should "order v4 before v6" do
      assert @a1 < IP.new("::1")
    end

    should "compare < >" do
      @a2 = IP.new("2.3.4.5")
      assert @a1 < @a2
      assert @a2 > @a1
    end

    should "use prefix as tiebreaker" do
      @a2 = IP.new("1.2.3.4/30")
      assert @a1 > @a2   # @a1 has /32 prefix length
    end
    
    should "use ctx as tiebreaker" do
      @a2 = IP.new("1.2.3.4@bar")
      @a3 = IP.new("1.2.3.4@foo")
      assert @a1 < @a2   # @a1 has no ctx
      assert @a2 < @a3
    end
  end

  context "hashing" do
    should "implement eql?" do
      assert IP.new("1.2.3.96@tst").eql?(IP.new("1.2.3.96@tst"))
    end
    
    should "implement hash" do
      assert_equal IP.new("1.2.3.96@tst").hash, IP.new("1.2.3.96@tst").hash
    end
        
    should "be able to use IP as hash key" do
      @hash = {IP.new("1.2.3.96@tst")=>1, IP.new("1.2.3.111@tst")=>2}
      assert_equal 1, @hash[IP.new("1.2.3.96@tst")]
      assert_equal 2, @hash[IP.new("1.2.3.111@tst")]
    end
  end

  context "freezing" do
    setup do
      @addr = IP.new('1.2.3.4/24@foo').freeze
    end

    should "be able to get values without a TypeError" do
      assert_nothing_raised(TypeError) do
        @addr.to_s
        @addr.to_addrlen
        @addr.to_addr
        @addr.to_arpa
        @addr.to_i
        @addr.to_b
        @addr.split
        @addr.to_a
        @addr.to_ah
        @addr.to_hex
        @addr.pfxlen
        @addr.proto
        @addr.to_irange
        @addr.to_range
        @addr.size
        @addr.ctx
        @addr.network
        @addr.broadcast
        @addr.mask
        @addr.netmask
        @addr.wildmask
        @addr.offset
      end
    end
  end

  context "range between two IPs" do
    should "be able to iterate" do
      r = IP.new("10.0.0.6")..IP.new("10.0.0.8")
      a = []
      r.each { |x| a << x.to_s }
      assert_equal ["10.0.0.6","10.0.0.7","10.0.0.8"], a
    end

    should "iterate when prefix present" do
      # Spec question: should this increment in blocks of /30 or single IPs?
      # Iteration of single IPs is not really useful for v6; but then again,
      # having an off-base start IP isn't really useful either.
      r = IP.new("10.0.0.6/30")..IP.new("10.0.0.11/29")
      a = []
      r.each { |x| a << x.to_s }
      assert_equal ["10.0.0.6/30","10.0.0.10/30"], a
    end
  end
  
  PARSE_TESTS = [
    # ipv4
    [["v4", 0x01020304, 32],				"1.2.3.4"],
    [["v4", 0xffffffff, 32],				"255.255.255.255"],
    [nil,						"255.255.255.256"],
    [["v4", 0x01020304, 29],				"1.2.3.4/29"],
    [nil,						"1.2.3.4/33"],
    # ipv6
    [nil,						"Abc"],
    [["v6", 0x0abc0000000000000000000000000000, 128],	"Abc::"],
    [["v6", 0x0abc0000000000000000000000000000, 128],	"[Abc::]"],
    [["v6", 0x00000000000000000000000000000abc, 128],	"::Abc"],
    [nil,						"Abcde::"],
    [["v6", 0x12340000000000000000000000000005, 128],	"1234::5"],
    [["v6", 0x11122223333444455556666777788889, 128],	"1112:2223:3334:4445:5556:6667:7778:8889"],
    [["v6", 0x11122223333400005556666777788889, 128],	"1112:2223:3334::5556:6667:7778:8889"],
    [nil,						"1112:2223:3334:4445:5556:6667:7778"],
    [["v6", 0x00000000000000000000000000000001, 96],	"::1/96"],
    [["v6", 0x00000000000000000000000000000001, 96],	"[::1]/96"],
    [nil,						"[::1]/129"],
    [["v6", 0xc0a80001, 128],				"::192.168.0.1"],
    [["v6", 0x01020304, 120],				"::1.2.3.4/120"],
    [["v6", 0xffff01020304, 126],			"::ffff:1.2.3.4/126"],
    [["v6", 0xffff01020304, 126],			"::ffff:1.2.3.4/126"],
    [["v6", 0xffff01020304, 120],			"[::ffff:1.2.3.4]/120"],
  ]

  FORMAT_TESTS = [
    ["1.2.3.4",		["v4",0x01020304,32]],
    ["1.2.3.4/29",	["v4",0x01020304,29]],
    ["::1.2.3.4",	["v6",0x00000000000000000000000001020304,128]],
    ["abc::1/96",	["v6",0x0abc0000000000000000000000000001,96]],
  ]
    
  should "parse addresses" do
    PARSE_TESTS.each do |exp,src|
      res = IP.parse(src)
      assert_equal exp, exp ? res.to_a : res, "Testing #{src.inspect}"
    end
  end

  should "parse with routing context" do
    res = IP.parse("1.2.3.4/28@foo")
    assert_equal ["v4", 0x01020304, 28, "foo"], res.to_a
  end

  should "format addresses" do
    FORMAT_TESTS.each do |exp,src|
      assert_equal exp, IP.new(src).to_s, "Testing #{src.inspect}"
    end
  end
end
