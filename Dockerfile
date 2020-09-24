FROM jenkins/jenkins:lts

ADD plugins.txt /tmp/plugins.txt
ADD casc_config.yml /tmp/jenkins_bootstrap.yml

USER root
RUN apt-get update && \
    apt-get install maven
USER jenkins
ENV JAVA_OPTS "-Djenkins.install.runSetupWizard=false"
ENV CASC_JENKINS_CONFIG "/tmp/jenkins_bootstrap.yml"
RUN /usr/local/bin/install-plugins.sh < /tmp/plugins.txt
