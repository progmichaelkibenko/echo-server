from http.server import HTTPServer, BaseHTTPRequestHandler
from io import BytesIO

class Handler(BaseHTTPRequestHandler):
    def do_POST(self):
        content_length = int(self.headers['Content-Length'])
        body = self.rfile.read(content_length)
        self.send_response(200)
        self.end_headers()
        response = BytesIO()
        response.write(b'Received:')
        response.write(body)
        self.wfile.write(response.getvalue())


print('Server listening on port 8000...')
httpd = HTTPServer(('localhost', 8000), Handler)
httpd.serve_forever()