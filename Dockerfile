# INSTALL PYTHON IMAGE
#FROM python:3.6
FROM centos:centos7
MAINTAINER Luis Hernandez <luisrh01@hotmail.com>

# INSTALL TOOLS AND PYTHON 36
RUN yum -y update
RUN yum -y install  unzip \
    && yum -y install  libaio-devel \
    && yum -y install https://centos7.iuscommunity.org/ius-release.rpm \
    && yum  -y install python36u python36u-libs python36u-devel python36u-pip \
    && yum -y install python-pip \
    && mkdir -p /opt/data/api

# SETUP ENV FOR R
RUN chmod g+w /etc/passwd && \
#    chmod +x /usr/bin/entrypoint.sh && \
    useradd -u 1000 -g root -d /home/user --shell /bin/bash -m user && \
    chmod g+rwx /home/user

# INSTALL OS DEPENDENCIES NEEDED BY R LIBRARIES AND R
RUN yum -y install openssl-devel cyrus-sasl-devel libcurl-devel psmisc gcc gcc-c++ make libxml2-devel unixODBC unixODBC-devel
RUN yum -y install wget git R
RUN pip install --upgrade pip
RUN pip3 install --upgrade pip

ADD ./oracle-instantclient/ /opt/data
ADD ./install-instantclient.sh /opt/data
ADD ./requirements.txt /opt/data
#ADD ./packages.txt /opt/database

WORKDIR /opt/data

ENV ORACLE_HOME=/opt/oracle/instantclient
ENV LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$ORACLE_HOME

ENV OCI_HOME=/opt/oracle/instantclient
ENV OCI_LIB_DIR=/opt/oracle/instantclient
ENV OCI_INCLUDE_DIR=/opt/oracle/instantclient/sdk/include

# INSTALL ORACLE INSTANTCLIENT, rpy2 AND PYTHON CODE DEPENDENCIES
USER root
RUN ["/bin/bash","./install-instantclient.sh"]
RUN pip install rpy2
RUN pip install -r requirements.txt

# SET UP R USER ENVIRONMENT
ENV USER=ruser \
    PASSWORD=ruser \
    HOME=/home/user
RUN echo "PATH=${PATH}" >> /usr/lib64/R/etc/Renviron \
    && mkdir /usr/share/doc/R-3.6.0/html \
    && mkdir /home/user/projects

# INSTALL PACKAGES FOR R - NEED TO CONFIGURE
USER 1000
# WORKDIR /home/user/projects
#RUN R -e "install.packages('plumber',dependencies=TRUE)"

EXPOSE 5000
WORKDIR /opt/data
CMD ["python","./api/server.py"]
