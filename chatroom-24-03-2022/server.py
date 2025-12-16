import socket
from sqlite3 import connect
import threading
import os
import time
import asyncio

try:
    os.sytsem('cls')
except:
    os.system('clear')

HEADER = 64
PORT = 5050
SERVER = socket.gethostbyname(socket.gethostname())
ADDR = (SERVER, PORT)
FORMAT = 'utf-8' 
DISCONNECT_MSG = '!DISCONNECT'
USER_MSG = '[USER]'

server = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
server.bind(ADDR)

class Client:
    def __init__(self, name, addr, conn):
        self.name = name
        self.conn = conn
        
clients = []
msg_list = []

def handle_client(conn, addr):
    print(f'[NEW CONNECTION] {addr} connected')
    connected = True
    while connected:
        msg_lenght = conn.recv(HEADER).decode(FORMAT)
        if msg_lenght:
            msg_lenght = int(msg_lenght) 
            msg = conn.recv(msg_lenght).decode(FORMAT)
            if msg == DISCONNECT_MSG:
                connected = False
                print(f'{addr} disconnected')
                print(f'[ACTIVE CONNECTIONS] {threading.activeCount() -1}')
            elif msg[0] == '[' and msg[5] == ']':
                cli = Client(msg, addr, conn)
                clients.append(cli)            
                conn.send('Username set'.encode(FORMAT))
            else:
                msg_list.append([cli, msg])
                        
                
    conn.close()

def loop():
    run = False
    run_loop = True
    while run_loop:
        if run == False:
            if len(msg_list) != 0:
                run = True
                last_msg = len(msg_list)
        else:
            time.sleep(1)
            if len(msg_list) > last_msg:
                try:
                    os.sytsem('cls')
                    os.system('clear')
                except:
                    os.system('clear')
                for client in clients:
                    msg_index = len(msg_list) - 1
                    conn = client.conn
                    conn.send(f'{msg_list[msg_index][0].name}: {msg_list[msg_index][1]}\n'.encode(FORMAT))
                    print('send')
            if len(msg_list) > last_msg:
                last_msg = len(msg_list)
            
        
def start():
    print(f'[LISTENING] Server is listening on {SERVER}')
    server.listen()
    while True:
        conn, addr = server.accept()
        thred = threading.Thread(target=handle_client, args=(conn, addr))
        thred.start()
        thred1 = threading.Thread(target=loop)
        thred1.start()
        print(f'[ACTIVE CONNECTIONS] {threading.activeCount() -1}')

print('[SERVER] Server starting...')
start()
