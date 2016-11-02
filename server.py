#!/usr/bin/env python
import sys, traceback
import SocketServer
import builder
from  framework.common import *
str_help = \
"""
Usage: vgt-get [Options] command [arg1 arg2 ...]
       vgt-get install software1 [software2 ...]
       vgt-get list [software] 

vgt-get is a simple command line interface for downloading and
installing packages. The most frequently used commands are install.

Commands:
   help    - This help text.
   install - Install new packages (pkg is libc6 not libc6.deb)
   list    - List software in server.

Options:
  --help               This help text.
  -h, --host=name      Connect to host.    
"""


def reply(str_data):
    def gen_help_code():
        return 'print """{0}"""'.format(str_help)
    def gen_error_code():
        return 'print "error command. for help..."\n' + gen_help_code()
    def gen_list_code(*args):
        print args
        if  not args:
            return 'print """{0}"""'.format( 
                reduce(lambda s1,s2:s1 + '\n' + s2, 
                       builder.xml_config.softwares.nodes.keys(),  
                       ''))
        else:
            return 'print "This function is developing..."'
    
    def gen_install_code(*args):
        print 'args = ',args
        str_software_id = args[0]
        if(len(args) == 1):
            str_commit = 'HEAD'
        elif(len(args) == 2):
            str_commit = args[1]

        return builder.software( str_software_id, str_commit ) \
            .get_python_code_for_install()
    
    try:
        list_data = eval(str_data)
        if '--help' in list_data:
            return gen_help_code()
        elif list_data[0] == 'list':
            return gen_list_code(*list_data[1:])
        elif list_data[0] == 'install':
            return gen_install_code(*list_data[1:])
        else:
            return  gen_error_code()
    except:
        traceback.print_exc()
        return gen_error_code()



class MyTCPHandler(SocketServer.BaseRequestHandler):
    def handle(self):
        self.data = self.request.recv(2048).strip()
        print "{} wrote:".format(self.client_address[0])
        print self.data
        self.request.sendall(reply(self.data))


if __name__ == "__main__":
    HOST, PORT = "localhost", 16180
    server = SocketServer.TCPServer((HOST, PORT), MyTCPHandler)
    server.serve_forever()
    




