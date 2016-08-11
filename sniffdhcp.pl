use IO::Socket::INET;
use Net::DHCP::Packet;
use Net::DHCP::Constants;

my $br_addr = sockaddr_in( '67', inet_aton('255.255.255.255') );
my $xid     = int( rand(0xFFFFFFFF) );
my $chaddr  = '0016cbb7c882';

my $socket = IO::Socket::INET->new(
    Proto     => 'udp',
    Broadcast => 1,
    LocalPort => '68',
) or die "Can't create socket: $@\n";

my $discover_packet = Net::DHCP::Packet->new(
    Xid                           => $xid,
    Chaddr                        => $chaddr,
    Flags                         => 0x8000,
    DHO_DHCP_MESSAGE_TYPE()       => DHCPDISCOVER(),
    DHO_HOST_NAME()               => 'Perl Test Client',
    DHO_VENDOR_CLASS_IDENTIFIER() => 'perl',

);

$socket->send( $discover_packet->serialize(), 0, $br_addr )
    or die "Error sending:$!\n";

my $buf = '';
$socket->recv( $buf, 4096 ) or die "recvfrom() failed:$!";
my $resp = new Net::DHCP::Packet($buf);

print "Received response from: " . $socket->peerhost() . "\n";
print "Details:\n" . $resp->toString();

close($socket);
