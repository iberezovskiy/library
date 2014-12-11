import parse as p
import collections

class Requirements():

    def __init__(self, base_url, project_name, branch, requirements_file):
        self.url = base_url + project_name + branch + requirements_file
        self.pars = p.Parse(self.url)

        self.sort()
        #write to file
        f = open('result.txt', 'w')
        for key in self.pars.reqs.keys():
            f.write("%s\n" % (str(key) + str(self.pars.reqs[key])))
        f.close()

    def sort(self):
        self.pars.reqs = collections.OrderedDict(sorted(self.pars.reqs.items()))

if __name__ == "__main__":
    requirements = Requirements('https://raw.githubusercontent.com/', 'openstack/glance/', 'master/', 'requirements.txt')