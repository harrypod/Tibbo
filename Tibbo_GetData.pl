### Connect to a TIBBO over UDP
## http://docs.tibbo.com/soism/index.html?command_telnet.htm

## 
use strict;
use Socket;

my $MAXLEN  = 1024;         
my $PORTNO  = 65535;        ##Open UDP port of TIBBO
my $HOSTNAME = "192.168.18.234";
my $LOGIN = "L";
my $REQUEST = "U";      ## status of Tibbo

print "Enter IP Address: \n";
my $HOSTNAME = <>;

my %BAUD =(1,"2400",2,"4800",3,"9600",4,"19200",5,"38400",6, "57600",7,"115200",11,"28800");


socket(SOCKET, PF_INET, SOCK_DGRAM, getprotobyname("udp")) 
    or die "socket: $!";

my $ipaddr   = inet_aton($HOSTNAME);
my $portaddr = sockaddr_in($PORTNO, $ipaddr);
send(SOCKET, $LOGIN, 0, $portaddr) == length($LOGIN)
        or die "cannot send to $HOSTNAME($PORTNO): $!";


$portaddr = recv(SOCKET, $LOGIN, $MAXLEN, 0)      or die "recv: $!";
my ($portno, $ipaddr) = sockaddr_in($portaddr);
print "Logged In: $LOGIN\n";
sleep 1;

my $ipaddr   = inet_aton($HOSTNAME);
my $portaddr = sockaddr_in($PORTNO, $ipaddr);
send(SOCKET, $REQUEST, 0, $portaddr) == length($REQUEST)
        or die "cannot send to $HOSTNAME($PORTNO): $!";


$portaddr = recv(SOCKET, $REQUEST, $MAXLEN, 0)      or die "recv: $!";
my ($portno, $ipaddr) = sockaddr_in($portaddr);
print "$HOSTNAME ($portno) replied: $REQUEST\n";

my @DATA = split "/", $REQUEST;

my $r_ip =  $DATA[0];
my $r_port =  $DATA[1];
my $r_eee =  $DATA[2];
my $r_ttt =  $DATA[3];
my $r_ccc =  $DATA[4];
my $r_sss =  $DATA[5];
my $r_fff =  $DATA[6];
my $r_r =  $DATA[7];
my $r_status =  $DATA[8];
my $r_inout =  $DATA[9];

#       ddd.ddd.ddd.ddd- IP-address of the network host with which the data connection is (was/ to be) established;
#       ppppp- data port number on the network host with which the data connection is (was/ to be) established;
#       eee- total number of characters in the Ethernet-to-serial buffer;
#       ttt- capacity of the Ethernet-to-serial buffer;
#       ccc- number of committed characters in the serial-to-Ethernet buffer;
#       sss- total number of characters in the serial-to-Ethernet buffer;
#       fff- capacity of the serial-to-Ethernet buffer;
#       r- current baudrate (same numbering is used as in the Baudrate (BR) setting);

## NEXT STRING = 
#       s- serial port state: '*' (closed), 'O' (opened);
#       d- serial port mode: 'F' (full-duplex), 'H' (half-duplex);
#       f- flow control: '*' (disabled), 'R' (RTS/CTS flow control);
#       p- parity: '*' (none), 'E' (even), 'O' (odd), 'M' (mark), 'S' (space);
#       b- bits per byte: '7' (7 bits), '8' (8 bits);
## NeXT
#       R- current state of the RTS (output) line: '*' (LOW*), 'R' (HIGH*);
#       C- current state of the CTS (input) line: '*' (LOW*), 'C' (HIGH*);
#       T- current state of the DTR (output) line: '*' (LOW*), 'T' (HIGH*);
#       S- current state of the DSR (input) line: '*' (LOW*), 'S' (HIGH*);

my %r_status_info = ("*","Disconnected - Awaiting Connection","O","Connected - Active Connection","F","Full-Duplex","H","Half-Duplex");
my %r_status_flowinfo = ("*","Disabled","R","RTS/CTS flow control");
my %r_status_parityinfo = ("*","None","E","Even","O","Odd","M","Mark","S","Space","7","7 Bits","8","8 Bits");
my %r_status_flowinfo = ("*","Disabled","R","RTS/CTS flow control");

my %r_output_states = ("*","Low","R","High","C","High","T","High","S","High");

my $a_baud = $BAUD{$r_r};
my @r_status_solo = split("", $r_status);
my @r_rtsstatus_solo = split("", $r_inout);


my $r_state         = $r_status_info{"$r_status_solo[0]"};
my $r_port_mode     = $r_status_info{"$r_status_solo[1]"};
my $r_flowcontrol   = $r_status_flowinfo{"$r_status_solo[2]"};
my $r_parity        = $r_status_parityinfo{"$r_status_solo[3]"};
my $r_bits          = $r_status_parityinfo{"$r_status_solo[4]"};

my $rts_state       = %r_output_states{"$r_rtsstatus_solo[0]"};
my $cts_state       = %r_output_states{"$r_rtsstatus_solo[1]"};
my $dtr_state       = %r_output_states{"$r_rtsstatus_solo[2]"};
my $dts_state       = %r_output_states{"$r_rtsstatus_solo[3]"};


print "-----------------------------\n";
print "Connected IP:        $r_ip\n";
print "Baud Rate:           $a_baud bps($r_r)\n";
print "Connection State:    $r_state\n";
print "Port Mode:           $r_port_mode\n";
print "Flow Control:        $r_flowcontrol\n";
print "Parity:              $r_parity\n";
print "Bits:                $r_bits\n";

print "RTS:                 $rts_state\n";
print "CTS:                 $cts_state\n";
print "DTR:                 $dtr_state\n";
print "DSR:                 $dts_state\n";

my $x = <>;
exit;

