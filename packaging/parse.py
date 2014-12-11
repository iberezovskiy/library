#!/usr/bin/env python

import sys
import urllib
import pip
import os
import requirements


class Parse():
    def __init__(self, url):
        filename = url.split('/')[-1]
        urllib.urlretrieve(url, filename)

        self.reqs = {}

        with open(filename, 'r') as f:
            for req in requirements.parse(f):
                self.reqs[str(req.values()[1]).lower()] = req.values()[2]

        for key in self.reqs.keys():
            self.reqs[key] = dict(self.reqs[key])
