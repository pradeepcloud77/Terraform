#!/usr/bin/env bash

### Spark
cd /home/centos
wget -P /home/centos http://apache.mivzakim.net/spark/spark-2.4.4/spark-2.4.4-bin-hadoop2.7.tgz
tar -xf spark-2.4.4-bin-hadoop2.7.tgz

./spark-2.4.4-bin-hadoop2.7/sbin/start-master.sh

# install conda and Jupyter
wget https://repo.anaconda.com/archive/Anaconda3-2019.03-Linux-x86_64.sh
bash /home/centos/Anaconda3-2019.03-Linux-x86_64.sh -b -p /home/centos/anaconda
eval "$(/home/centos/anaconda/bin/conda shell.bash hook)"
conda create -y -n jupyter
conda activate jupyter
conda install -y notebook
export SPARK_HOME="/home/centos/spark-2.4.4-bin-hadoop2.7"
conda install -y -c conda-forge findspark
conda install -y -c conda-forge jupyter_contrib_nbextensions
jupyter nbextension enable hinterland/hinterland
nohup jupyter notebook --allow-root --no-browser --ip 0.0.0.0 --NotebookApp.token='' > error.log & echo $!> jupyter_pid.txt



