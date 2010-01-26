class IP
  # Create an instance from an alternative array format:
  #   [context, protocol, address, prefix_length]
  def self.from_cpal(cpal)
    new([cpal[1], cpal[2], cpal[3], cpal[0]])
  end

  # Return an alternative 4-element array format with the routing context
  # as the first element. Useful for grouping by context.
  #    cpal = [context, proto, address, prefix_length]
  def to_cpal
    [@ctx, self.class::PROTO, @addr, @pfxlen]
  end

  # As cpal but with a hex string for the address part
  def to_cphl
    [@ctx, self.class::PROTO, to_hex, @pfxlen]
  end
end
