= pcap - a binding to libpcap

libpcap is the library behind the commonly use tcpdump utility. It allows
reading packet captures live from a network, as well as reading and writing
saved packet captures in "pcap" format. It has been ported to many operating
systems.

The binding doesn't implement the full libpcap API, just what we've needed so
far.

To build, see Makefile, it supports FreeBSD, Linux and OS X.

To decode the packets, you might want to use libnet's lua bindings, see the
lua/ subdirectory of <https://github.com/sam-github/libnet>.

Homepage: <https://github.com/sam-github/pcap-lua>
Author: <sroberts@wurldtech.com>

If this doesn't do what you need,
<https://github.com/javierguerragiraldez/pcaplua> is a binding to a different
subset of libpcap's API. Also, it has tcp/ip parsing functions, whereas we use
libnet for that.


Documentation:

See below, extracted from in-source comments.




** pcap - a binding to libpcap


-- pcap.DLT = { EN10MB=DLT_EN10MB, [DLT_EN10MB] = "EN10MB", ... }

DLT is a table of common DLT types. The DLT number and name are mapped to each other.

DLT.EN10MB is Ethernet (of all speeds, the name is historical).
DLT.LINUX_SLL can occur when capturing on Linux with a device of "any".

See <http://www.tcpdump.org/linktypes.html> for more information.

The numeric values are returned by cap:datalink() and accepted as linktype values
in pcap.open_dead().


-- cap = pcap.open_live(device, snaplen, promisc, timeout)

Open a source device to read packets from.


- device is the physical device (defaults to "any")

- snaplen is the size to capture, where 0 means max possible (defaults to 0)

- promisc is whether to set the device into promiscuous mode (default is false)

- timeout is the timeout for reads in seconds (default is 0, return if no packets available)



-- cap = pcap.open_dead([linktype, [snaplen]])


- linktype is one of the DLT numbers, and defaults to pcap.DLT.EN10MB.

- snaplen is the maximum size of packet, and defaults to 65535 (also,
  a value of 0 is changed into 65535 internally, as tcpdump does).

Open a pcap that doesn't read from either a live interface, or an offline pcap
file. It can be used with cap:dump_open() to write a pcap file, or to compile a
BPF program.


-- cap = pcap.open_offline(fname)

Open a savefile to read packets from.

An fname of "-" is a synonym for stdin.


-- cap:close()

Manually close a cap object, freeing it's resources (this will happen on
garbage collection if not done explicitly).


-- cap = cap:set_filter(filter, nooptimize)


- filter is the filter string, see tcpdump or pcap-filter man page.

- nooptimize can be true if you don't want the filter optimized during compile
  (the default is to optimize).


-- num = cap:datalink()

Interpretation of the packet data requires knowing it's datalink type. This
function returns that as a number.

See pcap.DLT for more information.


-- snaplen = cap:snapshot()

The snapshot length.

For a live capture, snapshot is the maximum amount of the packet that will be
captured, for writing of captures, it is the maximum size of a packet that can
be written.


-- fd = cap:getfd()

Get a selectable file descriptor number which can be used to wait for packets.

Returns the descriptor number on success, or nil if no such descriptor is
available (see pcap_get_selectable_fd).


-- capdata, timestamp, wirelen = cap:next()

Example:

    for capdata, timestamp, wirelen in cap.next, cap do
      print(timestamp, wirelen, #capdata)
    end

Returns capdata, timestamp, wirelen on sucess:


- capdata is the captured data

- timestamp is in seconds, theoretically to microsecond accuracy

- wirelen is the packets original length, the capdata may be shorter

Returns nil,emsg on failure, where emsg is:


- "timeout", timeout on a live capture

- "closed", no more packets to be read from a file

- ... some other string returned from pcap_geterr() describing the error


-- sent = cap:inject(packet)

Injects packet.

Return is bytes sent on success, or nil,emsg on failure.


-- dumper = cap:dump_open(fname)

Open a dump file to write packets to.

An fname of "-" is a synonym for stdout.

Note that the dumper object is independent of the cap object, once
it's created (so the cap object can be closed if its not going to
be used).


-- dumper:close()

Manually close a dumper object, freeing it's resources (this will happen on
garbage collection if not done explicitly).


-- dumper = dumper:dump(pkt, [timestamp, [wirelen]])

pkt is the packet to write to the dumpfile.

timestamp of packet, defaults to 0, meaning the current time.

wirelen was the original length of the packet before being truncated to header
(defaults to length of header, the correct value if it was not truncated).

If only the header of the packet is available, wirelen should be set to the
original packet length before it was truncated. Also, be very careful to not
write a header that is longer than the caplen (which will 65535 unless a
different value was specified in open_live or open_dead), the pcap file
will not be valid.

Returns self on sucess.
Returns nil and an error msg on failure.

Note that arguments are compatible with cap:next(), and that since
pcap_dump() doesn't return error indicators only the failure
values from cap:next() will ever be returned.


-- dumper = dumper:flush()

Flush all dumped packets to disk.

Returns self on sucess.
Returns nil and an error msg on failure.


-- secs = pcap.tv2secs(seci, useci)

Combine seperate seconds and microseconds into one numeric seconds.


-- seci, useci = pcap.secs2tv(secs)

Split one numeric seconds into seperate seconds and microseconds.


-- pcap._LIB_VERSION = ...

The libpcap version string, as returned from pcap_lib_version().
