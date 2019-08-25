l0:	ldh [12]                     ; load eth type onto A (half word)
l1:	jeq #0x86dd, noMatch         ; if(eth_type = 0x86dd ||eth_type != 0x800) goto noMatch
l2:	jneq #0x800, noMatch         ; eth_type 0x86dd = ipv6
l3:	ldb [23]                     ; load ip proto into A (1 byte)
l4:	jneq #0x11, l56              ; if (ip_proto != 0x11) goto l56 ; Protocol 0x11 = UDP
l5:	ldh [20]                     ; load (flags + fragment offset) into A (half word)
l6:	jset #0x1fff, l56            ; if (any of the data in fragment offset is true) goto l56
l7:	ldx 4*([14] & 0xf)           ; load ip header len * 4 (1 byte bc of the &) ; x = 20
l8:	ldh [x+16]                   ; load destination port ; byte 14 in the UDP header
l9:	jneq #0xfa0, l56             ; if (dest_port != 4000) goto l56
l10:	ld [x+22]                  ; load 0x2a
l11:	jneq #0x6d6f6e69, l54      ; if (&0x2a != "moni") goto l54
l12:	ld [x+26]                  ; load 0x2e
l13:	jneq #0x746f7220, l54      ; if (&0x2e != "tor ") goto l54
l14:	ldb [x+30]                 ; load 0x32
l15:	jeq #0x0, l17
l16:	jlt #0x3d, match
l17:	jgt #0x7a, match
l18:	ldb [x+31]
l19:	jeq #0x0, l21
l20:	jlt #0x3d, match
l21:	jgt #0x7a, match
l22:	ldb [x+32]
l23:	jeq #0x0, l25
l24:	jlt #0x3d, match
l25:	jgt #0x7a, match
l26:	ldb [x+33]
l27:	jeq #0x0, l29
l28:	jlt #0x3d, match
l29:	jgt #0x7a, match
l30:	ldb [x+34]
l31:	jeq #0x0, l33
l32:	jlt #0x3d, match
l33:	jgt #0x7a, match
l34:	ldb [x+35]
l35:	jeq #0x0, l37
l36:	jlt #0x3d, match
l37:	jgt #0x7a, match
l38:	ldb [x+36]
l39:	jeq #0x0, l41
l40:	jlt #0x3d, match
l41:	jgt #0x7a, match
l42:	ldb [x+37]
l43:	jeq #0x0, l45
l44:	jlt #0x3d, match
l45:	jgt #0x7a, match
l46:	ldb [x+38]
l47:	jeq #0x0, l49
l48:	jlt #0x3d, match
l49:	jgt #0x7a, match
l50:	ldb [x+39]
l51:	jeq #0x0, l53
l52:	jlt #0x3d, match
l53:	jgt #0x7a, match
l54:	ldh [x+18]                        ;
l55:	jgt #0x1a, match                  ; if (&0x26 < 0x1a) goto match
l56:	ldh [20]                          ; load (flags + fragment offset) into A (half word)
l57:	jset #0x3fff, match, noMatch      ; if (any flag or offset is set ) goto match
match:	ret #0xffff                     ; accept 0xffff bytes of the packet
noMatch:	ret #0x0                      ; discard packet
