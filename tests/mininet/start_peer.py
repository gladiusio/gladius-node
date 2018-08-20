import subprocess
import os
import sys
import requests
import json
from time import sleep


def start_peer(node_name, discovery_ip):
    # Sign the intorduction message
    url = "http://localhost:3001/api/p2p/message/sign"
    # Get our local IP address
    s = subprocess.check_output(
        "ifconfig | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1' | head -n 1 | tail -n 2", shell=True).rstrip()
    data = '''{"message": {"node": {"ip_address": "''' + \
        s + '''"}}, "passphrase": "password"}'''
    singed_message = requests.post(url, data=data)
    singed_message_string = json.dumps(singed_message.json()['response'])

    print "sm: " + singed_message.text

    # Introduce to the discovery peer
    url = "http://localhost:3001/api/p2p/network/join"
    data = '''{"ip": "''' + discovery_ip + '''","passphrase": "password","signed_message": ''' + \
        singed_message_string + '''}'''
    response = requests.post(url, data=data).text
    print "intro: " + response

    sleep(5)

    # For good measure inform the peers we just learned about
    url = "http://localhost:3001/api/p2p/state/push_message"
    data = singed_message_string
    response = requests.post(url, data=data).text
    print "push: " + response

if __name__ == "__main__":
    start_peer(sys.argv[1], sys.argv[2])
