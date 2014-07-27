#
# Ubuntu Dockerfile
#
# https://github.com/dockerfile/ubuntu
#

# Pull base image.
FROM dockerfile/java

## Neo4J dependency: dockerfile/java
## get java from trusted build
MAINTAINER ccp999 <ccp999@gmail.com>

# Install zeromq
RUN \
  apt-get install -y libtool autoconf automake uuid-dev && \
  cd /tmp && \
  wget https://github.com/zeromq/jzmq/archive/master.zip && \
  unzip master.zip && \
  rm -f master.zip  && \
  cd jzmq-master && \
  ./autogen.sh && \
  ./configure && \
  make && \
  make install && \
  ldconfig && \
  export CLASSPATH = $CLASSPATH:/usr/local/share/java/zmq.jar && \
  export LD_LIBRARY_PATH = $LD_LIBRARY_PATH:/usr/local/lib && \
  echo $CLASSPATH && \
  echo $LD_LIBRARY_PATH && \
  rm -rf /tmp/jzmq-master

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

## clean sources
RUN apt-get clean

## turn on indexing: http://chrislarson.me/blog/install-neo4j-graph-database-ubuntu
## enable neo4j indexing, and set indexable keys to name,age
## run sed -i "s|#node_auto_indexing|node_auto_indexing|g" /var/lib/neo4j/conf/neo4j.properties
## run sed -i "s|#node_keys_indexable|node_keys_indexable|g" /var/lib/neo4j/conf/neo4j.properties

WORKDIR /

## entrypoint
cmd ["/bin/bash", "-c", "/launch.sh"]
