from http.server import HTTPServer, BaseHTTPRequestHandler
from io import BytesIO
import socket
hostname = socket.gethostname()
ip = socket.gethostbyname(hostname)
ipBytes = ip.encode()

class Handler(BaseHTTPRequestHandler):
    def do_POST(self):
        content_length = int(self.headers['Content-Length'])
        body = self.rfile.read(content_length)
        self.send_response(200)
        self.end_headers()
        response = BytesIO()
        response.write(ipBytes)
        response.write(b': Says:')
        response.write(body)
        self.wfile.write(response.getvalue())

print('Server listening on port 80...')
httpd = HTTPServer(('0.0.0.0', 80), Handler)
httpd.serve_forever()
