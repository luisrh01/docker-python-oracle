# INSTALL PYTHON IMAGE
#FROM python:3.6
FROM centos:centos7
MAINTAINER Luis Hernandez <luisrh01@hotmail.com>

# INSTALL TOOLS AND PYTHON 36
RUN yum -y update \
    && yum -y install  unzip \
    && yum -y install  libaio-devel \
    && yum -y install https://centos7.iuscommunity.org/ius-release.rpm \
    && yum  -y install python36u python36u-libs python36u-devel python36u-pip \
    && yum -y install python-pip \
    && mkdir -p /opt/data/api

ADD ./oracle-instantclient/ /opt/data
ADD ./install-instantclient.sh /opt/data
ADD ./requirements.txt /opt/data

WORKDIR /opt/data

ENV ORACLE_HOME=/opt/oracle/instantclient
ENV LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$ORACLE_HOME

ENV OCI_HOME=/opt/oracle/instantclient
ENV OCI_LIB_DIR=/opt/oracle/instantclient
ENV OCI_INCLUDE_DIR=/opt/oracle/instantclient/sdk/include

# INSTALL INSTANTCLIENT AND DEPENDENCIES
USER root
RUN ["/bin/bash","./install-instantclient.sh"]
RUN pip install --upgrade pip
RUN pip3 install --upgrade pip

RUN pip install -r requirements.txt

EXPOSE 5000

CMD ["python","./api/server.py"]
