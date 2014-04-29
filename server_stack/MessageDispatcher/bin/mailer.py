# -*- coding: utf-8 -*-
from __future__ import print_function

__author__ = 'krc'

from email.mime.text import MIMEText
from email.MIMEText import MIMEText
from email.mime.multipart import MIMEMultipart
from email.header import Header
from mailer_conf import Config
from smtplib import SMTP

import json
import sys
import codecs
UTF8Writer = codecs.getwriter('utf8')
sys.stdout = UTF8Writer(sys.stdout)

# Output wrappers.
def error(*objs):
    print("ERROR: ", *objs, file=sys.stderr)

def critical(*objs):
    print("ERROR: ", *objs, file=sys.stderr)

def debug(*objs):
    print("DEBUG: ", *objs, file=sys.stdout)

def info(*objs):
    print("INFO: ", *objs, file=sys.stdout)

if __name__ == "__main__":
    # Email encoding.
    text_subtype = 'UTF-8'

    try:
        email = json.loads(sys.argv[1])
    except:
        error ('Failed to parse command line argument! (Expected JSON string as first argument')
        sys.exit(1)
        
    # Field renames.
    sender      = email['from']
    subject     = Header(email['subject'], "utf-8")
    to          = email['to']
    cc          = email['cc']
    bcc         = email['bcc']

    try:
        msg = MIMEText(email['message_body'], _charset=text_subtype)
        msg['From']   = sender
        msg['Subject']= subject
        msg['To']     = ",".join(to)
        msg['CC']     = ",".join(cc)
        msg['BCC']    = ",".join(bcc)

        conn = SMTP(Config.smtp_server)
        conn.login(Config.smtp_username, Config.smtp_password)

        try:
            conn.sendmail(sender, to + cc + bcc, msg.as_string())
        finally:
            conn.close()

    except Exception, exception:
        critical("Mailer process failed with exception; %s" % str(exception))
	raise
        sys.exit(1);
