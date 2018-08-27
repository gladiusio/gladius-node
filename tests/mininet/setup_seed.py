import subprocess
import os
import sys
import requests
import json
from time import sleep
from distutils.dir_util import copy_tree


def setup_seed(node_name):
    # Setup our pool manager wallet
    copy_tree("/vagrant/tests/test_files/wallet", "/gladius/wallet")

    # Copy the test content files to our content folder
    copy_tree("/vagrant/tests/test_files/content_files/honest_files", "/gladius/content")
    copy_tree("/vagrant/tests/test_files/content_files/bad_files", "/gladius/content")

    # Start the controld in the background
    subprocess.Popen("/vagrant/build/gladius-controld >> /tmp/controld_%s.out 2>&1" % node_name,
                     env={"GLADIUSBASE": "/gladius"},
                     shell=True)

    # Wait for controld to start
    sleep(1)

    url = "http://localhost:3001/api/keystore/account/open"
    data = '''{"passphrase":"password"}'''
    response = requests.post(url, data=data).text
    print "unlock repsonse: " + response

    # Sign the initial message
    url = "http://localhost:3001/api/p2p/message/sign"
    # Get our local IP address
    s = subprocess.check_output(
        "ifconfig | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1' | head -n 1 | tail -n 2", shell=True).rstrip()
    data = '''{"message": {"node": {"ip_address": "''' + \
        s + '''"}}, "passphrase": "password"}'''

    print data
    singed_message = requests.post(url, data=data)
    singed_message_string = json.dumps(singed_message.json()['response'])

    print "sm: " + singed_message.text

    # Set up our state
    url = "http://localhost:3001/api/p2p/state/push_message"
    data = singed_message_string
    response = requests.post(url, data=data).text
    print "push: " + response

if __name__ == "__main__":
    setup_seed(sys.argv[1])
