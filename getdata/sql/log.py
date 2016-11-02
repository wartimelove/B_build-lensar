#!/usr/bin/python
#encoding: utf-8
import sys,traceback

def mes(message):
	print >> sys.stderr,message

def wt_file(file_content,num, default=None):
        file_object = open('result_data.tmp','a')
	content= '%r|\t%r|\t%r\t%r\t%r\t%r\n' % file_content
        try:
                wt=file_object.write(content)
        finally:
                file_object.close()

 
class loggingUtils :
     def __init__(self,logfile) :
         import logging
         self.logger = logging.getLogger(logfile)
         self.hdlr = logging.FileHandler(logfile)
         formatter = logging.Formatter('%(asctime)s %(levelname)s - %(message)s')
         self.hdlr.setFormatter(formatter)
         self.logger.addHandler(self.hdlr)
         self.logger.setLevel(logging.DEBUG)
 
     def debug(self,msg):
	 self.logger.debug( msg )
	 self.hdlr.flush()
 
     def error(self,eline):
         self.logger.error(eline)
         self.hdlr.flush()
 
     def error_sys(self,limit=None):
         exceptionType, exceptionValue, exceptionTraceback = sys.exc_info()
         if limit is None:
             if hasattr(sys, 'tracebacklimit'):
                 limit = sys.tracebacklimit
         n = 0
         eline = '\n'
         while exceptionTraceback is not None and (limit is None or n < limit):
             f = exceptionTraceback.tb_frame
             lineno = exceptionTraceback.tb_lineno
             co = f.f_code
             filename = co.co_filename
             name = co.co_name
             eline += ' File "%s", line %d, in %s \n ' % (filename,lineno,name)
             exceptionTraceback = exceptionTraceback.tb_next
             n = n+1
 
         eline+= "\n".join(traceback.format_exception_only(exceptionType, exceptionValue))
         self.logger.error(eline)
         self.hdlr.flush()

