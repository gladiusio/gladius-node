import subprocess
import os
import sys
import requests
import json
from time import sleep
from distutils.dir_util import copy_tree
from shutil import copyfile


# Copy the file into ram before writing it, this is to avoid the mininet issues
# with tempfs...
def copy_wallet():
    with open("/vagrant/tests/test_files/wallet/UTC--2018-07-30T18-37-15.166079921Z--6531a634bbb040b00f32718fa8d9fa197274f1d0") as f:
        with open("/gladius/wallet/UTC--2018-07-30T18-37-15.166079921Z--6531a634bbb040b00f32718fa8d9fa197274f1d0", "w") as f1:
            f1.write(f.read())


def copy_configs():
    with open("/vagrant/tests/test_files/configs/gladius-controld.toml") as f:
        with open("/gladius/gladius-controld.toml", "w") as f1:
            f1.write(f.read())
    with open("/vagrant/tests/test_files/configs/gladius-networkd.toml") as f:
        with open("/gladius/gladius-networkd.toml", "w") as f1:
            f1.write(f.read())


def copy_content():
    with open("/vagrant/tests/test_files/content_files/bad_files/test1") as f:
        with open("/gladius/content/demo.gladius.io/test1", "w") as f1:
            f1.write(f.read())
    with open("/vagrant/tests/test_files/content_files/honest_files/test2") as f:
        with open("/gladius/content/demo.gladius.io/test2", "w") as f1:
            f1.write(f.read())


def setup_seed(node_name):
    # Setup our pool manager wallet
    os.makedirs("/gladius/content")
    os.makedirs("/gladius/content/demo.gladius.io")
    os.makedirs("/gladius/wallet")

    # Setup wallet, content, and configs
    copy_wallet()
    copy_configs()
    # copy_content()

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
