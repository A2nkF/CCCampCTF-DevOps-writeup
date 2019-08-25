# Unofficial eBPF spec

The [official documentation for the eBPF instruction set][1] is in the
Linux repository. However, while it is concise, it isn't always easy to
use as a reference. This document lists each valid eBPF opcode.

[1]: https://www.kernel.org/doc/Documentation/networking/filter.txt

## Instruction encoding

An eBPF program is a sequence of 64-bit instructions. This project assumes each
instruction is encoded in host byte order, but the byte order is not relevant
to this spec.

All eBPF instructions have the same basic encoding:

    msb                                                        lsb
    +------------------------+----------------+----+----+--------+
    |immediate               |offset          |src |dst |opcode  |
    +------------------------+----------------+----+----+--------+

From least significant to most significant bit:

 - 8 bit opcode
 - 4 bit destination register (dst)
 - 4 bit source register (src)
 - 16 bit offset
 - 32 bit immediate (imm)

Most instructions do not use all of these fields. Unused fields should be
zeroed.

The low 3 bits of the opcode field are the "instruction class".
This groups together related opcodes.

LD/LDX/ST/STX opcode structure:

    msb      lsb
    +---+--+---+
    |mde|sz|cls|
    +---+--+---+

The `sz` field specifies the size of the memory location. The `mde` field is
the memory access mode. uBPF only supports the generic "MEM" access mode.

ALU/ALU64/JMP opcode structure:

    msb      lsb
    +----+-+---+
    |op  |s|cls|
    +----+-+---+

If the `s` bit is zero, then the source operand is `imm`. If `s` is one, then
the source operand is `src`. The `op` field specifies which ALU or branch
operation is to be performed.

## ALU Instructions

### 64-bit

Opcode | Mnemonic      | Pseudocode
-------|---------------|-----------------------
0x07   | add dst, imm  | dst += imm
0x0f   | add dst, src  | dst += src
0x17   | sub dst, imm  | dst -= imm
0x1f   | sub dst, src  | dst -= src
0x27   | mul dst, imm  | dst *= imm
0x2f   | mul dst, src  | dst *= src
0x37   | div dst, imm  | dst /= imm
0x3f   | div dst, src  | dst /= src
0x47   | or dst, imm   | dst \|= imm
0x4f   | or dst, src   | dst \|= src
0x57   | and dst, imm  | dst &= imm
0x5f   | and dst, src  | dst &= src
0x67   | lsh dst, imm  | dst <<= imm
0x6f   | lsh dst, src  | dst <<= src
0x77   | rsh dst, imm  | dst >>= imm (logical)
0x7f   | rsh dst, src  | dst >>= src (logical)
0x87   | neg dst       | dst = -dst
0x97   | mod dst, imm  | dst %= imm
0x9f   | mod dst, src  | dst %= src
0xa7   | xor dst, imm  | dst ^= imm
0xaf   | xor dst, src  | dst ^= src
0xb7   | mov dst, imm  | dst = imm
0xbf   | mov dst, src  | dst = src
0xc7   | arsh dst, imm | dst >>= imm (arithmetic)
0xcf   | arsh dst, src | dst >>= src (arithmetic)

### 32-bit

These instructions use only the lower 32 bits of their operands and zero the
upper 32 bits of the destination register.

Opcode | Mnemonic        | Pseudocode
-------|-----------------|------------------------------
0x04   | add32 dst, imm  | dst += imm
0x0c   | add32 dst, src  | dst += src
0x14   | sub32 dst, imm  | dst -= imm
0x1c   | sub32 dst, src  | dst -= src
0x24   | mul32 dst, imm  | dst *= imm
0x2c   | mul32 dst, src  | dst *= src
0x34   | div32 dst, imm  | dst /= imm
0x3c   | div32 dst, src  | dst /= src
0x44   | or32 dst, imm   | dst \|= imm
0x4c   | or32 dst, src   | dst \|= src
0x54   | and32 dst, imm  | dst &= imm
0x5c   | and32 dst, src  | dst &= src
0x64   | lsh32 dst, imm  | dst <<= imm
0x6c   | lsh32 dst, src  | dst <<= src
0x74   | rsh32 dst, imm  | dst >>= imm (logical)
0x7c   | rsh32 dst, src  | dst >>= src (logical)
0x84   | neg32 dst       | dst = -dst
0x94   | mod32 dst, imm  | dst %= imm
0x9c   | mod32 dst, src  | dst %= src
0xa4   | xor32 dst, imm  | dst ^= imm
0xac   | xor32 dst, src  | dst ^= src
0xb4   | mov32 dst, imm  | dst = imm
0xbc   | mov32 dst, src  | dst = src
0xc4   | arsh32 dst, imm | dst >>= imm (arithmetic)
0xcc   | arsh32 dst, src | dst >>= src (arithmetic)

### Byteswap instructions

Opcode           | Mnemonic | Pseudocode
-----------------|----------|-------------------
0xd4 (imm == 16) | le16 dst | dst = htole16(dst)
0xd4 (imm == 32) | le32 dst | dst = htole32(dst)
0xd4 (imm == 64) | le64 dst | dst = htole64(dst)
0xdc (imm == 16) | be16 dst | dst = htobe16(dst)
0xdc (imm == 32) | be32 dst | dst = htobe32(dst)
0xdc (imm == 64) | be64 dst | dst = htobe64(dst)

## Memory Instructions

Opcode | Mnemonic              | Pseudocode
-------|-----------------------|--------------------------------
0x18   | lddw dst, imm         | dst = imm
0x20   | ldabsw src, dst, imm  | See kernel documentation
0x28   | ldabsh src, dst, imm  | ...
0x30   | ldabsb src, dst, imm  | ...
0x38   | ldabsdw src, dst, imm | ...
0x40   | ldindw src, dst, imm  | ...
0x48   | ldindh src, dst, imm  | ...
0x50   | ldindb src, dst, imm  | ...
0x58   | ldinddw src, dst, imm | ...
0x61   | ldxw dst, [src+off]   | dst = *(uint32_t *) (src + off)
0x69   | ldxh dst, [src+off]   | dst = *(uint16_t *) (src + off)
0x71   | ldxb dst, [src+off]   | dst = *(uint8_t *) (src + off)
0x79   | ldxdw dst, [src+off]  | dst = *(uint64_t *) (src + off)
0x62   | stw [dst+off], imm    | *(uint32_t *) (dst + off) = imm
0x6a   | sth [dst+off], imm    | *(uint16_t *) (dst + off) = imm
0x72   | stb [dst+off], imm    | *(uint8_t *) (dst + off) = imm
0x7a   | stdw [dst+off], imm   | *(uint64_t *) (dst + off) = imm
0x63   | stxw [dst+off], src   | *(uint32_t *) (dst + off) = src
0x6b   | stxh [dst+off], src   | *(uint16_t *) (dst + off) = src
0x73   | stxb [dst+off], src   | *(uint8_t *) (dst + off) = src
0x7b   | stxdw [dst+off], src  | *(uint64_t *) (dst + off) = src

## Branch Instructions

Opcode | Mnemonic            | Pseudocode
-------|---------------------|------------------------
0x05   | ja +off             | PC += off
0x15   | jeq dst, imm, +off  | PC += off if dst == imm
0x1d   | jeq dst, src, +off  | PC += off if dst == src
0x25   | jgt dst, imm, +off  | PC += off if dst > imm
0x2d   | jgt dst, src, +off  | PC += off if dst > src
0x35   | jge dst, imm, +off  | PC += off if dst >= imm
0x3d   | jge dst, src, +off  | PC += off if dst >= src
0xa5   | jlt dst, imm, +off  | PC += off if dst < imm
0xad   | jlt dst, src, +off  | PC += off if dst < src
0xb5   | jle dst, imm, +off  | PC += off if dst <= imm
0xbd   | jle dst, src, +off  | PC += off if dst <= src
0x45   | jset dst, imm, +off | PC += off if dst & imm
0x4d   | jset dst, src, +off | PC += off if dst & src
0x55   | jne dst, imm, +off  | PC += off if dst != imm
0x5d   | jne dst, src, +off  | PC += off if dst != src
0x65   | jsgt dst, imm, +off | PC += off if dst > imm (signed)
0x6d   | jsgt dst, src, +off | PC += off if dst > src (signed)
0x75   | jsge dst, imm, +off | PC += off if dst >= imm (signed)
0x7d   | jsge dst, src, +off | PC += off if dst >= src (signed)
0xc5   | jslt dst, imm, +off | PC += off if dst < imm (signed)
0xcd   | jslt dst, src, +off | PC += off if dst < src (signed)
0xd5   | jsle dst, imm, +off | PC += off if dst <= imm (signed)
0xdd   | jsle dst, src, +off | PC += off if dst <= src (signed)
0x85   | call imm            | Function call
0x95   | exit                | return r0


## Full

```
SYNTAX

The BPF architecture resp. register machine consists of the following elements:


    Element          Description


    A                32 bit wide accumulator
    X                32 bit wide X register
    M[]              16 x 32 bit wide misc registers aka "scratch memory store", addressable from 0 to 15

A program, that is translated by bpfc into ''opcodes'' is an array that consists of the following elements:


    o:16, jt:8, jf:8, k:32

The element o is a 16 bit wide opcode that has a particular instruction encoded, jt and jf are two 8 bit wide jump targets, one for condition element k contains a miscellaneous argument that can be interpreted in different ways depending on the given instruction resp. opcode.

The instruction set consists of load, store, branch, alu, miscellaneous and return instructions that are also represented in bpfc syntax. This table also includes bpfc's own extensions. All operations are based on unsigned data structures:
```
seccomp_data:
```c
struct seccomp_data {
     int nr;
     __u32 arch;
     __u64 instruction_pointer;
     __u64 args[6];
};
```
doc
```
Instruction      Addressing mode      Description


 ld               1, 2, 3, 4, 10       Load word into A
 ldi              4                    Load word into A
 ldh              1, 2                 Load half-word into A
 ldb              1, 2                 Load byte into A
 ldx              3, 4, 5, 10          Load word into X
 ldxi             4                    Load word into X
 ldxb             5                    Load byte into X


 st               3                    Copy A into M[]
 stx              3                    Copy X into M[]


 jmp              6                    Jump to label
 ja               6                    Jump to label
 jeq              7, 8                 Jump on k == A
 jneq             8                    Jump on k != A
 jne              8                    Jump on k != A
 jlt              8                    Jump on k < A
 jle              8                    Jump on k <= A
 jgt              7, 8                 Jump on k > A
 jge              7, 8                 Jump on k >= A
 jset             7, 8                 Jump on k & A


 add              0, 4                 A + <x>
 sub              0, 4                 A - <x>
 mul              0, 4                 A * <x>
 div              0, 4                 A / <x>
 mod              0, 4                 A % <x>
 neg              0, 4                 !A
 and              0, 4                 A & <x>
 or               0, 4                 A | <x>
 xor              0, 4                 A ^ <x>
 lsh              0, 4                 A << <x>
 rsh              0, 4                 A >> <x>


 tax                                   Copy A into X
 txa                                   Copy X into A


 ret              4, 9                 Return


 Addressing mode  Syntax               Description


  0               x                    Register X
  1               [k]                  BHW at byte offset k in the packet
  2               [x + k]              BHW at the offset X + k in the packet
  3               M[k]                 Word at offset k in M[]
  4               #k                   Literal value stored in k
  5               4*([k]&0xf)          Lower nibble * 4 at byte offset k in the packet
  6               L                    Jump label L
  7               #k,Lt,Lf             Jump to Lt if true, otherwise jump to Lf
  8               #k,Lt                Jump to Lt if predicate is true
  9               a                    Accumulator A
 10               extension            BPF extension (see next table)


 Extension (and alias)                 Description


 #len, len, #pktlen, pktlen            Length of packet (skb->len)
 #pto, pto, #proto, proto              Ethernet type field (skb->protocol)
 #type, type                           Packet type (**) (skb->pkt_type)
 #poff, poff                           Detected payload start offset
 #ifx, ifx, #ifidx, ifidx              Interface index (skb->dev->ifindex)
 #nla, nla                             Netlink attribute of type X with offset A
 #nlan, nlan                           Nested Netlink attribute of type X with offset A
 #mark, mark                           Packet mark (skb->mark)
 #que, que, #queue, queue, #Q, Q       NIC queue index (skb->queue_mapping)
 #hat, hat, #hatype, hatype            NIC hardware type (**) (skb->dev->type)
 #rxh, rxh, #rxhash, rxhash            Receive hash (skb->rxhash)
 #cpu, cpu                             Current CPU (raw_smp_processor_id())
 #vlant, vlant, #vlan_tci, vlan_tci    VLAN TCI value (vlan_tx_tag_get(skb))
 #vlanp, vlanp                         VLAN present (vlan_tx_tag_present(skb))


 Further extension details (**)        Value


 #type, type                           0 - to us / host
                                       1 - to all / broadcast
                                       2 - to group / multicast
                                       3 - to others (promiscuous mode)
                                       4 - outgoing of any type


 #hat, hat, #hatype, hatype            1 - Ethernet 10Mbps
                                       8 - APPLEtalk
                                      19 - ATM
                                      24 - IEEE 1394 IPv4 - RFC 2734
                                      32 - InfiniBand
                                     768 - IPIP tunnel
                                     769 - IP6IP6 tunnel
                                     772 - Loopback device
                                     778 - GRE over IP
                                     783 - Linux-IrDA
                                     801 - IEEE 802.11
                                     802 - IEEE 802.11 + Prism2 header
                                     803 - IEEE 802.11 + radiotap header
                                     823 - GRE over IP6
                                     824 - Netlink
                                     [...] See include/uapi/linux/if_arp.h
```
