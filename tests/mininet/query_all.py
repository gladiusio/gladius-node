#!/usr/bin/python
import sys
import requests
import json


def query_nodes(nodes):
    results = {}
    state_set = set()
    for node in nodes:
        url = "http://%s:3001/api/p2p/state/" % node
        state = requests.get(url).text
        state_set.add(state)
        results[node] = json.loads(state)

    results_len = len(state_set)
    if (results_len > 1):
        print json.dumps(results)
        print "Test failed, there were %d results." % results_len
    else:
        print json.dumps(results)
        print "Test passed!"


if __name__ == '__main__':
    query_nodes(sys.argv[1:])
