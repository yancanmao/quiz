from http.server import BaseHTTPRequestHandler, HTTPServer
import os

class SimpleHTTPRequestHandler(BaseHTTPRequestHandler):
    def do_GET(self):
        # Try reading from ConfigMap first
        if os.path.exists('/data/hello.txt'):
            with open('/data/hello.txt', 'r') as file:
                message = file.read()
        else:
            # Write the client's message to hello.txt
            with open('/data/hello.txt', 'w') as file:
                file.write("Hello World")
            message = "File/Config Not Found"
        
        self.send_response(200)
        self.send_header('Content-type', 'text/plain')
        self.end_headers()
        self.wfile.write(message.encode())

if __name__ == '__main__':
    httpd = HTTPServer(('0.0.0.0', 8080), SimpleHTTPRequestHandler)
    httpd.serve_forever()

