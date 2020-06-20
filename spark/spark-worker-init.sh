#!/usr/bin/env bash

### Spark
cd ~
wget -P /home/centos http://apache.mivzakim.net/spark/spark-2.4.4/spark-2.4.4-bin-hadoop2.7.tgz
cd /home/centos
tar -xf spark-2.4.4-bin-hadoop2.7.tgz
./spark-2.4.4-bin-hadoop2.7/sbin/start-slave.sh spark://${master_ip}:7077


