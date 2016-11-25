FROM ubuntu:xenial

ARG jenkins_swarm_client_version="2.2"
ARG name="jenkins_swarm_slave"
ARG fsroot="/home/jenkins"
ARG log_file="/var/log/swarm-client.log"
ARG container_user="jenkins"
ARG labels="docker"

ENV JENKINS_SWARM_CLIENT_VERSION $jenkins_swarm_client_version
ENV NAME $name
ENV FSROOT $fsroot
ENV LOG_FILE $log_file
ENV CONTAINER_USER $container_user
ENV LABELS $labels
ENV PACKAGES_LIST="apt-transport-https\
 build-essential\
 curl\
 git\
 libffi-dev\
 libgmp-dev\
 libpq-dev\
 libssl-dev\
 libsqlite3-0\
 libvirt-bin\
 libyaml-dev\
 mariadb-client\
 openjdk-8-jre-headless\
 pkg-config\
 python\
 python-dev\
 python-pip\
 python-tox\
 python-virtualenv\
 qemu-kvm\
 qemu-utils\
 shellcheck\
 ssh\
 sudo\
 software-properties-common\
 sshpass\
 unzip\
 wget"

# Packages
RUN apt-get update
COPY files/ansible_pin.pref /etc/apt/preferences.d/ansible_pin.pref
COPY files/kernel_pin.pref /etc/apt/preferences.d/kernel_pin.pref

RUN DEBIAN_FRONTEND=noninteractive apt-get -o Dpkg::Options::=--force-confdef -o Dpkg::Options::=--force-confold -q -y \
dist-upgrade --allow-downgrades

RUN apt-get install --no-install-recommends ${PACKAGES_LIST} -y --force-yes

# Install docker
RUN apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys F76221572C52609D
RUN echo 'deb https://apt.dockerproject.org/repo ubuntu-xenial main' | tee /etc/apt/sources.list.d/docker.list
RUN apt-get update
RUN apt-get install --no-install-recommends docker-engine -y --force-yes

# User
RUN useradd -m -d ${FSROOT} -s /bin/bash -c "${CONTAINER_USER}" -U ${CONTAINER_USER}
RUN echo "${CONTAINER_USER} ALL=(root) NOPASSWD: ALL" > /etc/sudoers.d/10_${CONTAINER_USER}
RUN usermod -a -G libvirtd,kvm,docker ${CONTAINER_USER}
RUN touch ${LOG_FILE}
RUN chown ${CONTAINER_USER}:${CONTAINER_USER} ${LOG_FILE}

# Slave jar
RUN wget https://repo.jenkins-ci.org/releases/org/jenkins-ci/plugins/swarm-client/${JENKINS_SWARM_CLIENT_VERSION}/\
swarm-client-${JENKINS_SWARM_CLIENT_VERSION}-jar-with-dependencies.jar -P ${FSROOT}
RUN chown ${CONTAINER_USER}:${CONTAINER_USER} ${FSROOT}/swarm-client-${JENKINS_SWARM_CLIENT_VERSION}-jar-with-dependencies.jar

CMD java -jar ${FSROOT}/swarm-client-${JENKINS_SWARM_CLIENT_VERSION}-jar-with-dependencies.jar \
-name ${NAME} -labels ${LABELS} -executors ${EXECUTORS} -username ${USERNAME} -password ${PASSWORD} \
-fsroot ${FSROOT} -master ${JENKINS_MASTER} -disableSslVerification &> ${LOG_FILE}
