# INSTALL PYTHON IMAGE
FROM centos:centos7
#FROM python:3.6-slim
MAINTAINER Luis Hernandez <luis.r.hernandez4@navy.mil>
#COPY certs/* /etc/pki/ca-trust/source/anchors/
#RUN update-ca-trust

# INSTALL TOOLS AND PYTHON 36
RUN yum -y update
RUN yum -y install  unzip \
    && yum -y install  libaio-devel \
    && mkdir -p /data/api \
    && mkdir -p /app

RUN yum install -y python36.x86_64 python36-devel.x86_64 python36-pip.noarch gcc sudo python36-setuptools && \
    easy_install-3.6 pip
    
# INSTALL OS DEPENDENCIES NEEDED BY R LIBRARIES AND R
RUN yum -y install openssl-devel cyrus-sasl-devel libcurl-devel psmisc gcc gcc-c++ make libxml2-devel unixODBC unixODBC-devel
RUN yum -y install wget git R
RUN pip install --trusted-host pypi.org --trusted-host files.pythonhosted.org --upgrade pip
RUN pip3 install --trusted-host pypi.org --trusted-host files.pythonhosted.org --upgrade pip
RUN pip3 install --trusted-host pypi.org --trusted-host files.pythonhosted.org Flask gunicorn

# SETUP ENV FOR R
RUN chmod g+w /etc/passwd && \
#    chmod +x /usr/bin/entrypoint.sh && \
    useradd -u 1000 -g root -d /home/user --shell /bin/bash -m user && \
    chmod g+rwx /home/user

ADD ./api/server.py /data/api
ADD ./oracle-instantclient/ /data
ADD ./install-instantclient.sh /data
ADD ./prerequirements.txt /data
ADD ./requirements.txt /data

WORKDIR /data

ENV ORACLE_HOME=/opt/oracle/instantclient
ENV LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$ORACLE_HOME

ENV OCI_HOME=/opt/oracle/instantclient
ENV OCI_LIB_DIR=/opt/oracle/instantclient
ENV OCI_INCLUDE_DIR=/opt/oracle/instantclient/sdk/include

# INSTALL ORACLE INSTANTCLIENT, rpy2 AND PYTHON CODE DEPENDENCIES
USER root

RUN ["/bin/bash","./install-instantclient.sh"]
RUN pip install --trusted-host pypi.org --trusted-host files.pythonhosted.org -r prerequirements.txt
RUN pip install --trusted-host pypi.org --trusted-host files.pythonhosted.org -r requirements.txt

WORKDIR "/app"
COPY ["service", "/app"]
RUN touch log.txt && \
    chmod a+w log.txt 

#Expose pod ports
EXPOSE 8080

#Start gunicorn and have it point to the exposed port
CMD ["/usr/local/bin/gunicorn", "--bind", "0.0.0.0:8080", "-c", "python:GunicornConfig", "GunicornStart:application"]
