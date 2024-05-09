from http.server import BaseHTTPRequestHandler, HTTPServer

class EchoHTTPRequestHandler(BaseHTTPRequestHandler):
    def do_POST(self):
        content_length = int(self.headers['Content-Length'])
        post_data = self.rfile.read(content_length)
        self.send_response(200)
        self.send_header('Content-type', 'text/plain')
        self.end_headers()
        self.wfile.write(post_data)

if __name__ == '__main__':
    server_address = ('', 8080)  # Listen on all interfaces
    httpd = HTTPServer(server_address, EchoHTTPRequestHandler)
    print("Echo server running on port 8080...")
    httpd.serve_forever()
