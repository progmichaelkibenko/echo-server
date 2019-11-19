import socket
import sys

def connect(): 
    sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)

    server_address = ('0.0.0.0', 5000)
    sock.bind(server_address)

    sock.listen(1)

    while True:
        connection, client_address = sock.accept()
        try:
            while True:
                data = connection.recv(16)
                if data:
                    connection.sendall(data)
                else:
                    break
            
        finally:
            connection.close()

connect()