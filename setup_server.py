from http.server import BaseHTTPRequestHandler, HTTPServer
from os import curdir, sep, path, getcwd, chdir
import os
import cgi
import subprocess
import time

class testHTTPServer_RequestHandler(BaseHTTPRequestHandler):

    def do_POST(self):
        formdata = cgi.FieldStorage(
            fp=self.rfile,
            headers=self.headers,
            environ={'REQUEST_METHOD': 'POST'})

        self.send_response(200)
        self.end_headers()
        self.server.stop = True
        self.server.set_credentials( formdata.getvalue('ssid'), formdata.getvalue('password') )

    def do_GET(self):
        if self.path == "/":
            self.path = "/index.html"

        # try to open the requested file....
        try:
            f = open( curdir + sep + 'www' + sep + self.path )
        except IOError:
            print("Failed to open file");
            self.send_response(400);
            self.end_headers()
            return

        # succeeded in opening the file, handle the request
        self.send_response(200)
        self.send_header('Content-type','text/html')
        self.end_headers()
        self.wfile.write(bytes(f.read(),'utf-8'))
        f.close()
        return

class stoppableHTTPServer( HTTPServer ):
    def __init__( self, address, handler ):
        super().__init__( address, handler )
        self.ssid = ''
        self.password = ''      

    def serve_forever(self):
        self.stop = False
        while not self.stop:
            self.handle_request()

    def set_credentials(self,ssid,password):
        self.ssid = ssid
        self.password = password

def run():
    work_dir   = os.getcwd()
    script_dir = os.path.dirname(os.path.realpath(__file__))
    os.chdir( script_dir )

    val = subprocess.call(['./still_connected.sh'])

    if val:
        print('Setting up access point...');
        subprocess.call(['./setup_access_point.sh'])

        print('Starting server...')
        server_address = ('10.10.10.1',80)
        httpd = stoppableHTTPServer(server_address,testHTTPServer_RequestHandler)
        httpd.serve_forever()

        print('Received credentials were: ' + httpd.ssid + ' ' + httpd.password )
        val = subprocess.call(['./setup_network.sh',httpd.ssid,httpd.password])
        time.sleep(10)
        
    os.chdir( work_dir );
run()
