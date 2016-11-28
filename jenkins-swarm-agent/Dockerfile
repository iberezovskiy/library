FROM ubuntu:xenial

ARG jenkins_swarm_client_version="2.2"
ARG fsroot="/home/jenkins"
ARG container_user="jenkins"

ENV JENKINS_SWARM_CLIENT_VERSION $jenkins_swarm_client_version
ENV USERNAME ""
ENV PASSWORD ""
ENV JENKINS_MASTER ""
ENV EXECUTORS 1
ENV NAME "jenkins_swarm_slave"
ENV FSROOT $fsroot
ENV LOG_FILE $log_file
ENV CONTAINER_USER $container_user
ENV LABELS "swarm"

RUN apt-get update && apt-get install apt-transport-https -y --force-yes
RUN apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys F76221572C52609D &&\
echo 'deb https://apt.dockerproject.org/repo ubuntu-xenial main' | tee /etc/apt/sources.list.d/docker.list

RUN apt-get update && apt-get install --no-install-recommends curl\
 docker-engine\
 gcc\
 git\
 libffi-dev\
 libgmp-dev\
 libpq-dev\
 libssl-dev\
 libsqlite3-0\
 libyaml-dev\
 mariadb-client\
 openjdk-8-jre-headless\
 pkg-config\
 python\
 python-dev\
 python-pip\
 python-setuptools\
 python-tox\
 python-virtualenv\
 python-wheel\
 shellcheck\
 ssh\
 sudo\
 software-properties-common\
 sshpass\
 unzip\
 wget -y --force-yes && apt-get clean

# User
RUN useradd -m -d ${FSROOT} -s /bin/bash -c "${CONTAINER_USER}" -U ${CONTAINER_USER} &&\
echo "${CONTAINER_USER} ALL=(root) NOPASSWD: ALL" > /etc/sudoers.d/10_${CONTAINER_USER} &&\
usermod -a -G docker ${CONTAINER_USER}

# Slave jar
RUN su - ${CONTAINER_USER} -c "wget https://repo.jenkins-ci.org/releases/org/jenkins-ci/plugins/swarm-client/${JENKINS_SWARM_CLIENT_VERSION}/\
swarm-client-${JENKINS_SWARM_CLIENT_VERSION}-jar-with-dependencies.jar -P ${FSROOT}"

CMD java -jar ${FSROOT}/swarm-client-${JENKINS_SWARM_CLIENT_VERSION}-jar-with-dependencies.jar \
-name ${NAME} -labels ${LABELS} -executors ${EXECUTORS} -username ${USERNAME} -password ${PASSWORD} \
-fsroot ${FSROOT} -master ${JENKINS_MASTER} -disableSslVerification 2>&1
