# Copyright (C) 2009-2010 Brian Candler <http://www.deploy2.net/>
# Licensed under the same terms as ruby. See LICENCE.txt and COPYING.txt

require 'socket'

class IP
  # Return the address family, Socket::AF_INET or Socket::AF_INET6
  def af
    self.class::AF
  end

  # Convert to a packed sockaddr structure  
  def to_sockaddr(port=0)
    Socket.pack_sockaddr_in(port, to_addr)
  end
  
  class V4
    AF = Socket::AF_INET
    PROTO_TO_CLASS[AF] = self

    # Avoid the string conversion when building sockaddr. Unfortunately this
    # fails 32-bit machines with 1.8.6 for addrs >= 0x80000000. There is
    # also no corresponding Socket.pack_sockaddr_in6 we could use for V6.

    #def to_sockaddr(port=0)
    #  Socket.pack_sockaddr_in(port, to_i)
    #end
  end
  
  class V6
    AF = Socket::AF_INET6
    PROTO_TO_CLASS[AF] = self
  end
end
