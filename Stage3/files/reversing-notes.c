- v0.0.11 -
packet matches if:
  - eth_type  = IPv4
  - protocol  = UDP
  - flags     = 000 (Packet isn't fragmented)
  - dest_port = 4000
  - data._0_8 = "monitor "
  -

pseudo:

int filterV11(packet){
      if(packet.eth_type == IPv6){
        goto noMatch;
      }
      if(packet.eth_type != IPv4){
        goto noMatch;
      }
      if(packet.protocol != UDP){
        goto noMatch;
      }
      if(packet.flags_frag & 0x1fff){
        goto noMatch;
      }

      udp_packet x = packet.udp_packet
      if(x.dest_port != 4000){
        goto noMatch;
      }
      if(x.data._0_8 != 0x6d6f6e69746f7220){ // 'monitor '
        goto check_size;
      }
      for(i=0; i<9; i++){                   // check if bytes 0x32-0x3b contain
        if(x.data[8+i] < (int)"="){         // chars not in [A-Z, a-z, [, \, ], ^, _, `]
          goto match;
        }
        if(x.data[8+i] > (int)"z"){
          goto match;
        }
      }

      check_size:
        if(packet.size <= 0x1a){
          goto noMatch;
        }

      noMatch:
        return 0;

      match:
        return 0xffff;
}

- v0.0.12 -
  -


pseudo

int filterV12(packet){
      if(packet.eth_type == IPv6){
        goto noMatch;
      }
      if(packet.eth_type != IPv4){
        goto noMatch;
      }
      if(packet.protocol != UDP){
        goto check_flags;
      }
      if(packet.flags_frag & 0x1fff){
        goto check_flags;
      }

      udp_packet x = packet.udp_packet
      if(x.dest_port != 4000){
        goto check_flags;
      }
      if(x.data._0_8 != 0x6d6f6e69746f7220){ // 'monitor '
        goto check_size;
      }
      for(i=0; i<9; i++){                   // check if bytes 0x32-0x3b contain
        if(x.data[8+i] < (int)"="){         // chars not in [A-Z, a-z, [, \, ], ^, _, `]
          goto match;
        }
        if(x.data[8+i] > (int)"z"){
          goto match;
        }
      }

      check_size:
        if(packet.size > 0x1a){
          goto match;
        }

      check_flags:
        if(packet.flags_frag & 0x3fff){
          goto match;
        } else {
          goto noMatch;
        }

      match:
        return 0xffff;

      noMatch:
        return 0;
}



PACKET STRUCTURE:
0x00: destination address (6 bytes)
0x06: unknown (2 bytes)
0x08: source address (6 bytes)
0x0e: unknown



Result:
bypass filter using fragmented packets
