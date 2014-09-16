#!/usr/bin/env python

import sys
import urllib


class Requirements():

    def __init__(self, branch='master'):
        self.base_url = 'https://raw.githubusercontent.com/'
        self.branch = branch

        self.core = ['glance', 'nova', 'neutron', 'cinder', 'swift',
                     'sahara', 'ceilometer', 'heat', 'horizon', 'keystone',
                     'python-glanceclient', 'python-novaclient',
                     'python-neutronclient', 'python-cinderclient',
                     'python-swiftclient', 'python-saharaclient',
                     'python-ceilometerclient', 'python-heatclient',
                     'python-keystoneclient']
        self.core_url = self.base_url + 'openstack/'

        self.stackforge = ['murano', 'python-muranoclient']
        self.stackforge_url = self.base_url + 'stackforge/'

        self.oslo = ['.messaging', '.vmware', '-incubator', '.utils',
                     '.serialization', '.middleware', '.log', '.db',
                     '.concurrency', '.rootwrap', 'sphinx', '.i18n', '.config',
                     '.version', 'test', '.version']
        self.oslo_url = self.base_url + '/openstack/oslo'

        self.global_requirements_file = 'global-requirements.txt'
        self.requirements_file = 'requirements.txt'

        self.global_requirements = self.get_list_requirements(
            self.core_url + 'requirements/' + branch + '/' +
            self.global_requirements_file)
        self.result = self.analyze()

        self.write_to_file()

    def get_list_requirements(self, url):
        filename = url.split('/')[-1]
        urllib.urlretrieve(url, filename)

        f = open(filename, 'rb')
        first_line = f.readline()
        if 'NotFound' in first_line:
            print 'Can\'t download %s' % url
            return []
        content = f.readlines()
        f.close()

        deps = []

        for line in content:
            if len(line.replace(' ', '')) != 0 \
                    and len(line.rstrip()) != 0 \
                    and not line.startswith('#'):
                deps.append(self.parse_deps_conditions(line))

        return deps

    def analyze(self):
        all_requirements = {}
        for repo in self.core:
            requirements = self.get_list_requirements(
                self.core_url + repo + '/' + self.branch + '/' +
                self.requirements_file)
            all_requirements = self.check_existence_and_append(
                all_requirements, requirements)

        for repo in self.oslo:
            requirements = self.get_list_requirements(
                self.oslo_url + repo + '/' + self.branch + '/' +
                self.requirements_file)
            all_requirements = self.check_existence_and_append(
                all_requirements, requirements)

        for repo in self.stackforge:
            requirements = self.get_list_requirements(
                self.stackforge_url + repo + '/' + self.branch + '/' +
                self.requirements_file)
            all_requirements = self.check_existence_and_append(
                all_requirements, requirements)

        return all_requirements

    def check_existence_and_append(self, all_requirements, requirements):
        for elem in requirements:
            if not all_requirements.keys().__contains__(elem[0]):
                all_requirements[elem[0]] = elem[1]

        return all_requirements

    def get_name_cond_of_deps(self, set):
        deps = []
        if set is not None:
            for line in set:
                deps.append(self.parse_deps_conditions(line))

        return deps

    def parse_deps_conditions(self, dep):
        name = None
        cond = None
        if '#' in dep:
            dep = dep.split('#')[0]
        if ' ' in dep:
            dep = dep.replace(' ', '')

        if '>=' in dep or '>' in dep:
            name = dep.rsplit('>')[0]
            cond = dep.rsplit(name)[1]
        elif '==' in dep:
            name = dep.split('=')[0]
            cond = dep.split(name)[1]
        elif '<=' in dep or '<' in dep:
            name = dep.split('<')[0]
            cond = dep.split(name)[1]
        elif '!=' in dep:
            name = dep.split('!')[0]
            cond = dep.split(name)[1]
        else:
            name = dep
            cond = ''
        return name.rstrip(), cond.rstrip()

    def write_to_file(self):
        f = open('requirements', 'w')
        import operator
        self.result = sorted(self.result.items(),
                             cmp=lambda x, y: cmp(x[0].lower(), y[0].lower()))
        for key, value in self.result:
            f.write("%s\n" % (key + value))
        f.close()
        print self.result

if __name__ == "__main__":
    requirements = Requirements()
