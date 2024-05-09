from http.server import BaseHTTPRequestHandler, HTTPServer
import http.client
import json

class ProxyHTTPRequestHandler(BaseHTTPRequestHandler):
    def do_POST(self):
        content_length = int(self.headers['Content-Length'])
        post_data = self.rfile.read(content_length).decode('utf-8')
        request_data = json.loads(post_data)
        
        # Extract the server IP and message from the client's request
        server_ip = request_data['server_ip']
        server_port = request_data['server_port']
        message = request_data['message']

        # Forward the request to the echo server
        print(server_ip, server_port)
        conn = http.client.HTTPConnection(server_ip, server_port)
        conn.request("POST", "/", body=message, headers={"Content-Type": "text/plain"})
        response = conn.getresponse()
        response_data = response.read()

        # Send back the response from the echo server to the client
        self.send_response(200)
        self.send_header('Content-type', 'text/plain')
        self.end_headers()
        self.wfile.write(response_data)
        conn.close()

if __name__ == '__main__':
    server_address = ('', 8888)
    httpd = HTTPServer(server_address, ProxyHTTPRequestHandler)
    print("Proxy server running on port 8888...")
    httpd.serve_forever()
