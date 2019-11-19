import socket
import sys

# 52.137.24.147:80

server_ip = '52.137.24.147'
server_port = 80

try:
    server_ip = sys.argv[1]
    server_port = int(sys.argv[2])
except IndexError:
    print("echo-client> Trying to connect to the default minikube ip {0}:{1}".format(server_ip, server_port))

print("echo-client> Connection started")

sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)

server_address = (server_ip, server_port)

try:
    sock.connect(server_address)
    print("echo-client> Connected to {0}:{1} type exit to exit".format(server_ip, server_port))
    msg = input("client>")
    while msg != 'exit':
        sock.sendall(msg.encode('utf-8'))
        data = sock.recv(16)
        print("Received: %s" % data.decode('utf-8'))
        msg = input("client>")
except socket.gaierror as e:
    print("Socket error: %s" % str(e))
except Exception as e:
    print(e)
finally:
    sock.close()
