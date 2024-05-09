import http.client
import json
import sys

def send_to_proxy(data, proxy_ip, proxy_port):
    conn = http.client.HTTPConnection(proxy_ip, proxy_port)
    headers = {'Content-type': 'application/json'}
    json_data = json.dumps(data)
    conn.request('POST', '/', body=json_data, headers=headers)
    response = conn.getresponse()
    print('Response from server:', response.read().decode())
    conn.close()

if __name__ == '__main__':
    if len(sys.argv) != 6:
        print("Usage: python client.py <proxy_ip> <proxy_port> <server_ip> <server_port> <message>")
        sys.exit(1)

    proxy_ip = sys.argv[1]
    proxy_port = int(sys.argv[2])
    
    data = {
        "server_ip": sys.argv[3],  # Echo server IP
        "server_port": sys.argv[4],
        "message": sys.argv[5]
    }
    send_to_proxy(data, proxy_ip, proxy_port)
