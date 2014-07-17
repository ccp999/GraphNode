#
# Ubuntu Dockerfile
#
# https://github.com/dockerfile/ubuntu
#

# Pull base image.
FROM ubuntu:14.04

## Neo4J dependency: dockerfile/java
## get java from trusted build
MAINTAINER ccp999 <ccp999@gmail.com>

# Install.
RUN \
  sed -i 's/# \(.*multiverse$\)/\1/g' /etc/apt/sources.list && \
  apt-get update && \
  apt-get -y upgrade && \
## clean sources
  apt-get clean && \
  apt-get install -y build-essential && \
  apt-get install -y software-properties-common && \
  apt-get install -y byobu curl git htop man unzip vim wget

# Install Python.
RUN apt-get install -y python python-dev python-pip python-virtualenv

# Add files.
ADD root/.bashrc /root/.bashrc
ADD root/.gitconfig /root/.gitconfig
ADD root/scripts /root/scripts

# Set environment variables.
ENV HOME /root

# Define working directory.
WORKDIR /root

# Install Node.js
RUN \
  cd /tmp && \
  wget http://nodejs.org/dist/node-latest.tar.gz && \
  tar xvzf node-latest.tar.gz && \
  rm -f node-latest.tar.gz && \
  cd node-v* && \
  ./configure && \
  CXX="g++ -Wno-unused-local-typedefs" make && \
  CXX="g++ -Wno-unused-local-typedefs" make install && \
  cd /tmp && \
  rm -rf /tmp/node-v* && \
  echo '\n# Node.js\nexport PATH="node_modules/.bin:$PATH"' >> /root/.bash_profile

# Install Java.
RUN \
  echo debconf shared/accepted-oracle-license-v1-1 select true | debconf-set-selections && \
  echo debconf shared/accepted-oracle-license-v1-1 seen true | debconf-set-selections && \
  add-apt-repository -y ppa:webupd8team/java && \
  apt-get update && \
  apt-get install -y oracle-java7-installer

## install neo4j according to http://www.neo4j.org/download/linux
# Import neo4j signing key
RUN wget -O - http://debian.neo4j.org/neotechnology.gpg.key | apt-key add - 
# Create an apt sources.list file
RUN echo 'deb http://debian.neo4j.org/repo stable/' > /etc/apt/sources.list.d/neo4j.list
# Find out about the files in neo4j repo ; install neo4j community edition
RUN apt-get update ; apt-get install neo4j -y

## add launcher and set execute property
add launch.sh /
run chmod +x /launch.sh

## turn on indexing: http://chrislarson.me/blog/install-neo4j-graph-database-ubuntu
## enable neo4j indexing, and set indexable keys to name,age
## run sed -i "s|#node_auto_indexing|node_auto_indexing|g" /var/lib/neo4j/conf/neo4j.properties
## run sed -i "s|#node_keys_indexable|node_keys_indexable|g" /var/lib/neo4j/conf/neo4j.properties

## entrypoint
cmd ["/bin/bash", "-c", "/launch.sh"]
