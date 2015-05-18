FROM ubuntu:14.04

RUN apt-get update && apt-get install -y python2.7 python-biopython sqlite3
ADD / /opt
ENV PYTHONPATH /opt
