#!/usr/bin/env python
import requirs as r
import requests
import collections

class Test_Requirements:
    def __init__(self, url, requirements_file, branch):

        self.test_requirements = {}

        self.openstack_names = ['glance', 'nova', 'neutron', 'cinder', 'swift',
                     'sahara', 'ceilometer', 'heat', 'horizon', 'keystone',
                     'python-glanceclient', 'python-novaclient',
                     'python-neutronclient', 'python-cinderclient',
                     'python-swiftclient', 'python-saharaclient',
                     'python-ceilometerclient', 'python-heatclient',
                     'python-keystoneclient']
        self.projects = {}
        for elem in self.openstack_names:
            key = 'openstack/' + str(elem) + '/'
            if self.exists(url + key + branch + requirements_file):
                self.projects[key] = \
                    r.Requirements(url, key, branch, requirements_file).pars.reqs

        self.stackforge_names = ['murano', 'python-muranoclient']

        for elem in self.stackforge_names:
            key = 'stackforge/' + str(elem) + '/'
            if self.exists(url + key + branch + requirements_file):
                self.projects[key] = \
                    r.Requirements(url, key, branch, requirements_file).pars.reqs

        self.oslo = ['.messaging', '.vmware', '-incubator', '.utils',
                     '.serialization', '.middleware', '.log', '.db',
                     '.concurrency', '.rootwrap', 'sphinx', '.i18n', '.config',
                     '.version', 'test', '.version']

        for elem in self.oslo:
            key = 'openstack/oslo' + str(elem) + '/'
            if self.exists(url + key + branch + requirements_file):
                self.projects[key] =\
                    r.Requirements(url, key, branch, requirements_file).pars.reqs
            else:
                tmp_requitements_file = 'test-requirements-py2.txt'
                if self.exists(url + key + branch + tmp_requitements_file):
                    self.projects[key] =\
                    r.Requirements(url, key, branch, tmp_requitements_file).pars.reqs
                else:
                    continue

        for elem in self.projects:
            for key in self.projects[elem].keys():
                if key not in self.test_requirements:
                    self.test_requirements[str(key)] = str(self.projects[elem][key])

        self.sort()
        #write to file
        f = open('result.txt', 'w')
        for key in self.test_requirements:
            f.write("%s\n" % (str(key) + ' ' + str(self.test_requirements[key])))
        f.close()

    def sort(self):
        self.test_requirements = collections.OrderedDict(sorted(self.test_requirements.items()))

    def exists(site, path):
        r = requests.head(path)
        return r.status_code == requests.codes.ok

if __name__ == "__main__":
    test_requirements = Test_Requirements('https://raw.githubusercontent.com/', 'test-requirements.txt', 'master/')