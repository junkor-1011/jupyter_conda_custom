# 

ARG BASE_IMAGE=ubuntu:18.04
FROM $BASE_IMAGE

#ARG USER_NAME=user
#ARG USR_UID=1000

USER root

ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    openjdk-8-jre-headless \
    wget \
    curl \
    bzip2 \
    ca-certificates \
    sudo \
    graphviz \
    git \
    make \
    tk-dev \
    unzip \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*
# ToDo 要らないものを削ぎ落とす
#    build-essential \
#    locales \
#    fonts-liberation \
#    run-one \
#    xz-utils \
#    swig \
#    llvm \

# SPARK    
# https://qiita.com/hrkt/items/fe9b1162f7a08a07e812
# https://spark.apache.org/downloads.html
# https://www.apache.org/dyn/closer.lua/spark/spark-2.4.5/spark-2.4.5-bin-hadoop2.7.tgz
ARG SPARK_VERSION=2.4.5
ARG HADOOP_VERSION=2.7
#RUN curl -O https://spark.apache.org/downloads.html/spark/spark-${SPARK_VERSION}/spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}.tgz \
RUN curl -O http://apache.mirror.iphh.net/spark/spark-${SPARK_VERSION}/spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}.tgz \
    && tar xzf spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}.tgz \
    && mv spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION} /usr/local/spark \
    && rm spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}.tgz
# ToDo もう少し早くDownload出来るミラーが無いか確認する



# 一般ユーザーアカウントを追加
ARG USER_NAME=user
ARG USER_UID=1000
ARG PASSWD=password
#ARG USER_GID=100

ENV CONDA_DIR=/opt/conda \
    HOME=/home/$USER_NAME \
    SHELL=/bin/bash

RUN useradd -m -s /bin/bash -u ${USER_UID} ${USER_NAME} && \
    gpasswd -a ${USER_NAME} sudo && \
    echo "${USER_NAME}:${PASSWD}" | chpasswd && \
    echo "${USER_NAME} ALL=(ALL) ALL" >> /etc/sudoers && \
    mkdir -p $CONDA_DIR && \
    chown $USER_NAME:$USER_UID $CONDA_DIR && \
    chmod g+w /etc/passwd
#RUN echo "auth requisite pam_deny.so" >> /etc/pam.d/su && \
#    sed -i.bak -e 's/^%admin/#%admin/' /etc/sudoers && \
#    sed -i.bak -e 's/^%sudo/#%sudo/' /etc/sudoers && \
#    useradd -m -s /bin/bash -N -u $USER_UID $USER_NAME && \
#    mkdir -p $CONDA_DIR && \
#    chown $USER_NAME:$USER_UID $CONDA_DIR && \
#    chmod g+w /etc/passwd

# ubuntu color-prompt
RUN sed -i 's/^#force_color_prompt=yes/force_color_prompt=yes/' /etc/skel/.bashrc

USER $USER_NAME
WORKDIR $HOME
ARG PYTHON_VERSION=default


# ToDo Versionの調整と、不要な設定の除去
# ref https://hub.docker.com/r/jupyter/base-notebook/dockerfile
ENV MINICONDA_VERSION=4.8.2 \
    MINICONDA_MD5=87e77f097f6ebb5127c77662dfc3165e \
    CONDA_VERSION=4.8.2 \
    PATH=$CONDA_DIR/bin:$PATH

RUN cd /tmp && \
    wget --quiet https://repo.continuum.io/miniconda/Miniconda3-py37_${MINICONDA_VERSION}-Linux-x86_64.sh && \
    echo "${MINICONDA_MD5} *Miniconda3-py37_${MINICONDA_VERSION}-Linux-x86_64.sh" | md5sum -c - && \
    /bin/bash Miniconda3-py37_${MINICONDA_VERSION}-Linux-x86_64.sh -f -b -p $CONDA_DIR && \
    rm Miniconda3-py37_${MINICONDA_VERSION}-Linux-x86_64.sh && \
    echo "conda ${CONDA_VERSION}" >> $CONDA_DIR/conda-meta/pinned && \
    conda config --system --prepend channels conda-forge && \
    conda config --system --set auto_update_conda false && \
    conda config --system --set show_channel_urls true && \
    conda config --system --set channel_priority strict && \
    if [ ! $PYTHON_VERSION = 'default' ]; then conda install --yes python=$PYTHON_VERSION; fi && \
    conda list python | grep '^python ' | tr -s ' ' | cut -d '.' -f 1,2 | sed 's/$/.*/' >> $CONDA_DIR/conda-meta/pinned && \
    conda install --quiet --yes conda && \
    conda install --quiet --yes pip && \
    conda update --all --quiet --yes && \
    conda clean --all -f -y && \
    rm -rf /home/$NB_USER/.cache/yarn

# Install Tini
RUN conda install --quiet --yes 'tini=0.18.0' && \
    conda list tini | grep tini | tr -s ' ' | cut -d ' ' -f 1,2 >> $CONDA_DIR/conda-meta/pinned && \
    conda clean --all -f -y

RUN conda install --quiet --yes \
    'notebook=6.0.3' \
    'jupyterhub=1.1.0' \
    'jupyterlab=2.0.1' && \
    conda clean --all -f -y && \
    npm cache clean --force && \
    jupyter notebook --generate-config && \
    rm -rf $CONDA_DIR/share/jupyter/lab/staging && \
    rm -rf $HOME/.cache/yarn

# custom setting



# JAVA_HOME & SPARK
ENV JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk-amd64 \
    SPARK_HOME=/usr/local/spark
ARG PY4J_VER=0.10.7

ENV PATH=$SPARK_HOME/bin:$PATH \
    PYTHONPATH=${SPARK_HOME}/python:${SPARK_HOME}/python/lib/py4j-${PY4J_VER}-src.zip \
    SPARK_OPTS="--driver-java-options=-Xms1024M --driver-java-options=-Xmx4096M --driver-java-options=-Dlog4j.logLevel=info" \
    PATH=${SPARK_HOME}/bin:$PATH \
    PYSPARK_PYTHON=${CONDA_DIR}/bin/python \
    PYSPARK_DRIVER=${CONDA_DIR}/bin/python

# add jar
RUN ${SPARK_HOME}/bin/pyspark --packages graphframes:graphframes:0.7.0-spark2.4-s_2.11
RUN ${SPARK_HOME}/bin/pyspark --packages org.postgresql:postgresql:jar:42.1.4



# FONT
RUN mkdir ~/.fonts \
    && chown ${USER_NAME} ~/.fonts \
    && chmod 755 ~/.fonts
RUN wget https://ipafont.ipa.go.jp/IPAexfont/ipaexg00401.zip \
    && unzip ipaexg00401.zip \
    && mv ipaexg00401 -t ~/.fonts/ \
    && rm ipaexg00401.zip \
    && rm -rf ~/.cache/* \
    && fc-cache -fv


#RUN jupyter labextension install @jupyter-widgets/jupyterlab-manager
#RUN jupyter labextension install jupyter-matplotlib
#RUN jupyter labextension install @lckr/jupyterlab_variableinspector

EXPOSE 8888

ENTRYPOINT ["tini", "-g", "--"]
CMD ["jupyter", "lab", "--ip=0.0.0.0", "--port=8888", "--NotebookApp.token=''"]
