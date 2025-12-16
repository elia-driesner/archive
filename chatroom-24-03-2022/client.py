import socket
import os
import threading
import time

try:
    os.sytsem('cls')
except:
    os.system('clear')

HEADER = 64
PORT = 5050
FORMAT = 'utf-8'
DISCONNECT_MSG = '!DISCONNECT'
SERVER = socket.gethostbyname(socket.gethostname())
ADDR = (SERVER, PORT)
USER_MSG = '[USER]'

client = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
client.connect(ADDR)

def send(msg):
    message = msg.encode(FORMAT)
    msg_length = len(message)
    send_length = str(msg_length).encode(FORMAT)
    send_length +=  b' ' * (HEADER - len(send_length))
    client.send(send_length)
    client.send(message)

def recv():
    run = True
    while run:
        time.sleep(0.1)
        print(f'{client.recv(2048).decode(FORMAT)}')
    
run = True

print('Enter a Username')
username = input()
send(f'{USER_MSG}{username}')

time.sleep(0.1)
try:
    os.sytsem('cls')
except:
    os.system('clear')

thred = threading.Thread(target=recv)

thred.start()

while run:
    msg = input()
    if msg == 'exit':
        run = False
        send(DISCONNECT_MSG)
    elif msg == 'cl':
        os.system('clear')
    else:
        send(msg)