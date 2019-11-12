import socket

def listen():
    connection = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    connection.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    connection.bind(('0.0.0.0', 5000))
    connection.listen(10)
    print("Connected")
    while True:
        current_connection, address = connection.accept()
        while True:
            data = current_connection.recv(2048)
            print(data)
            current_connection.send(data)

if __name__ == "__main__":
    listen()