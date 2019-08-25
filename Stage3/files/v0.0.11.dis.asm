l0:	ldh [12]                  ; load eth type onto A (half word)
l1:	jeq #0x86dd, noMatch      ; if(eth_type = 0x86dd || eth_type != 0x800) goto noMatch
l2:	jneq #0x800, noMatch      ; eth_type 0x86dd = ipv6
l3:	ldb [23]                  ; load ip proto into A (1 byte)
l4:	jneq #0x11, noMatch       ; if (ip_proto != 0x11) goto noMatch ; Protocol 0x11 = UDP
l5:	ldh [20]                  ; load (flags + fragment offset) into A (half word)
l6:	jset #0x1fff, noMatch     ; if (any of the data in fragment offset is true) goto noMatch
                              ; datagram can't be fragmented
l7:	ldx 4*([14] & 0xf)        ; load ip header len * 4 (1 byte bc of the &) ; x = 20
l8:	ldh [x+16]                ; load destination port ; byte 14 in the UDP header
l9:	jneq #0xfa0, noMatch      ; if (dest_port != 4000) goto noMatch
l10:	ld [x+22]               ; load 0x2a
l11:	jneq #0x6d6f6e69, l54   ; if (&0x2a != "moni") goto noMatch
l12:	ld [x+26]               ; load 0x2e
l13:	jneq #0x746f7220, l54   ; if (&0x2e != "tor ") goto noMatch
l14:	ldb [x+30]              ; load 0x32
l15:	jeq #0x0, l17           ; if (&0x32 == 0x00) goto l17
l16:	jlt #0x3d, match        ; if (&0x32 < 0x3d) goto match
l17:	jgt #0x7a, match        ; if (&0x32 > 0x7a) goto match
l18:	ldb [x+31]              ; load 0x33
l19:	jeq #0x0, l21           ; if (&0x33 == 0x00) goto l21
l20:	jlt #0x3d, match        ; if (&0x33 < 0x3d) goto match
l21:	jgt #0x7a, match        ; if (&0x33 > 0x7a) goto match
l22:	ldb [x+32]              ; load 0x34
l23:	jeq #0x0, l25           ; if (&0x34 == 0x00) goto l25
l24:	jlt #0x3d, match        ; if (&0x34 < 0x3d) goto match
l25:	jgt #0x7a, match        ; if (&0x34 > 0x7a) goto match
l26:	ldb [x+33]              ; load 0x35
l27:	jeq #0x0, l29           ; if (&0x35 == 0x00) goto l25
l28:	jlt #0x3d, match        ; if (&0x35 < 0x3d) goto match
l29:	jgt #0x7a, match        ; if (&0x35 > 0x7a) goto match
l30:	ldb [x+34]              ; load 0x36
l31:	jeq #0x0, l33           ; if (&0x36 == 0x00) goto l33
l32:	jlt #0x3d, match        ; if (&0x36 < 0x3d) goto match
l33:	jgt #0x7a, match        ; if (&0x36 > 0x7a) goto match
l34:	ldb [x+35]              ; load 0x37
l35:	jeq #0x0, l37           ; if (&0x37 == 0x00) goto l37
l36:	jlt #0x3d, match        ; if (&0x37 < 0x3d) goto match
l37:	jgt #0x7a, match        ; if (&0x37 > 0x7a) goto match
l38:	ldb [x+36]              ; load 0x38
l39:	jeq #0x0, l41           ; if (&0x38 == 0x00) goto l41
l40:	jlt #0x3d, match        ; if (&0x38 < 0x3d) goto match
l41:	jgt #0x7a, match        ; if (&0x38 > 0x7a) goto match
l42:	ldb [x+37]              ; load 0x39
l43:	jeq #0x0, l45           ; if (&0x39 == 0x00) goto l45
l44:	jlt #0x3d, match        ; if (&0x39 < 0x3d) goto match
l45:	jgt #0x7a, match        ; if (&0x39 > 0x7a) goto match
l46:	ldb [x+38]              ; load 0x3a
l47:	jeq #0x0, l49           ; if (&0x3a == 0x00) goto l49
l48:	jlt #0x3d, match        ; if (&0x3a < 0x3d) goto match
l49:	jgt #0x7a, match        ; if (&0x3a > 0x7a) goto match
l50:	ldb [x+39]              ; load 0x3b
l51:	jeq #0x0, l53           ; if (&0x3b == 0x00) goto l53
l52:	jlt #0x3d, match        ; if (&0x3b < 0x3d) goto match
l53:	jgt #0x7a, match        ; if (&0x3b > 0x7a) goto match
l54:	ldh [x+18]              ; load 0x26
l55:	jle #0x1a, noMatch      ; if (&0x26 <= 0x1a) goto noMatch
match:	ret #0xffff           ; accept 0xffff bytes of the packet
noMatch:	ret #0x0            ; discard packet
