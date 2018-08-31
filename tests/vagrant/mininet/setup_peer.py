import subprocess
import os
import sys
import requests
import json
from time import sleep
from shutil import copyfile


def setup_peer(node_name):
    os.makedirs("/gladius/content")
    os.makedirs("/gladius/content/demo.gladius.io")

    # Copy configs
    copy_configs()

    # Start the controld in the background
    subprocess.Popen("/vagrant/build/gladius-controld >> /tmp/controld_%s.out 2>&1" % node_name,
                     env={"GLADIUSBASE": "/gladius"},
                     shell=True)

    # Wait for controld to start
    sleep(5)

    # Create an account
    url = "http://localhost:3001/api/keystore/account/create"
    data = '''{"passphrase":"password"}'''
    response = requests.post(url, data=data).text
    print "account response: " + response

    url = "http://localhost:3001/api/keystore/account/open"
    data = '''{"passphrase":"password"}'''
    response = requests.post(url, data=data).text
    print "unlock repsonse: " + response


def copy_configs():
    with open("/vagrant/tests/test_files/configs/gladius-controld.toml") as f:
        with open("/gladius/gladius-controld.toml", "w") as f1:
            f1.write(f.read())
    with open("/vagrant/tests/test_files/configs/gladius-networkd.toml") as f:
        with open("/gladius/gladius-networkd.toml", "w") as f1:
            f1.write(f.read())


if __name__ == "__main__":
    setup_peer(sys.argv[1])
