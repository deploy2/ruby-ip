require 'test_helper'
require 'ip/base'
require 'ip/cpal'

class IPTestRPAL < Test::Unit::TestCase
  context "v4" do
    setup do
      @addr = IP.new("1.2.3.4/24@foo")
    end

    should "build from cpal" do
      res = IP.from_cpal(["bar", "v4", 0x01020304, 26])
      assert_equal IP::V4, res.class
      assert_equal "1.2.3.4/26@bar", res.to_s
    end

    should "have to_cpal" do
      assert_equal ["foo","v4", 0x01020304, 24], @addr.to_cpal
    end

    should "have to_cphl" do
      assert_equal ["foo","v4", "01020304", 24], @addr.to_cphl
    end
  end

  context "v6" do
    should "build from cpal" do
      res = IP.from_cpal(["bar", "v6", 0xdeadbeef000000000000000000000123, 48])
      assert_equal IP::V6, res.class
      assert_equal "dead:beef::123/48@bar", res.to_s
    end
  end
end
