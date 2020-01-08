FROM centos:6.7
MAINTAINER Star Lab <support@starlab.io>

RUN mkdir /source

# Install yum-plugin-ovl to work around issue with a bad
# rpmdb checksum
RUN yum install --disablerepo=updates,extras -y yum-plugin-ovl && \
    yum clean all && \
    rm -rf /var/cache/yum/* /tmp/* /var/tmp/*

# update certificates
RUN yum -y update ca-certificates nss wget curl && \
    yum clean all && \
    rm -rf /var/cache/yum/* /tmp/* /var/tmp/*

# build dependencies
RUN yum install --disablerepo=updates,extras -y kernel-devel bc \
        openssl openssl-devel python-setuptools python-virtualenv \
        dracut-network nfs-utils check unzip rpm-build rpm-devel \
        gcc perl elfutils-libelf-devel && \
    yum groupinstall --disablerepo=updates,extras -y "Development Tools" && \
    yum clean all && \
    rm -rf /var/cache/yum/* /tmp/* /var/tmp/*

# remove git if already installed
RUN yum remove -y git && \
    yum clean all && \
    rm -rf /var/cache/yum/* /tmp/* /var/tmp/*

# install IUS so we can get a recent version of git
RUN yum install -y https://centos6.iuscommunity.org/ius-release.rpm && \
    yum clean all && \
    rm -rf /var/cache/yum/* /tmp/* /var/tmp/*

# install modern git
RUN yum install -y git2u && \
    yum clean all && \
    rm -rf /var/cache/yum/* /tmp/* /var/tmp/*

# more utilities
RUN yum install --disablerepo=updates,extras -y \
        vim-common attr python-devel freetype-devel xxd && \
    yum clean all && \
    rm -rf /var/cache/yum/* /tmp/* /var/tmp/*

# user space app build dependencies
RUN yum install --disablerepo=updates,extras -y texinfo \
        glibc-static.x86_64 glibc-static.i686 autogen && \
    yum clean all && \
    rm -rf /var/cache/yum/* /tmp/* /var/tmp/*

# Install yum-utils
RUN yum install --disablerepo=updates,extras -y yum-utils && \
    yum clean all && \
    rm -rf /var/cache/yum/* /tmp/* /var/tmp/*

VOLUME ["/source"]
WORKDIR /source
CMD ["/bin/bash"]
