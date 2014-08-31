require 'test_helper'
require 'ip/cpal'

class IPTestRPAL < Minitest::Test
  describe "v4" do
    before do
      @addr = IP.new("1.2.3.4/24@foo")
    end

    it "builds from cpal" do
      res = IP.from_cpal(["bar", "v4", 0x01020304, 26])
      assert_equal IP::V4, res.class
      assert_equal "1.2.3.4/26@bar", res.to_s
    end

    it "has to_cpal" do
      assert_equal ["foo","v4", 0x01020304, 24], @addr.to_cpal
    end

    it "has to_cphl" do
      assert_equal ["foo","v4", "01020304", 24], @addr.to_cphl
    end
  end

  describe "v6" do
    it "builds from cpal" do
      res = IP.from_cpal(["bar", "v6", 0xdeadbeef000000000000000000000123, 48])
      assert_equal IP::V6, res.class
      assert_equal "dead:beef::123/48@bar", res.to_s
    end
  end
end
