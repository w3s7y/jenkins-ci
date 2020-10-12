FROM jenkins/jenkins:lts

USER root
RUN apt-get update && \
    apt-get install -y maven ca-certificates curl apt-transport-https lsb-release gnupg g++ \
        php-readline nodejs && \
    curl -sL https://aka.ms/InstallAzureCLIDeb | bash && \
    curl --output /usr/local/bin/kubectl -L "https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl" && \
    chmod -R 755 /usr/local/bin

USER jenkins
ADD plugins.txt /tmp/plugins.txt
RUN CURL_RETRY=10 /usr/local/bin/install-plugins.sh < /tmp/plugins.txt
