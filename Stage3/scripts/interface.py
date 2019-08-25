#!/usr/bin/env python3
import itertools
import socket


def recvall(sock):
    BUFF_SIZE = 4096 # 4 KiB
    data = b''
    while True:
        try:
            part = sock.recv(BUFF_SIZE)
            data += part
            if len(part) < BUFF_SIZE:
                # either 0 or end of data
                break
        except socket.timeout:
            pass
    return data

sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
sock.connect(('172.28.224.11', 4000))
sock.settimeout(0.1)

while 1:
    command = input("> ") + "\x00\x00\x00\x00"
    sock.send(command.encode())
    print(recvall(sock))
