#!/bin/bash

# ToDo:
#   - 必要な引数の整理
#   - イメージの選択 
#   - 使用port

# default port
PORT_USING=8889
# default user-name
USER_NAME=user

# https://qiita.com/b4b4r07/items/dcd6be0bb9c9185475bb
# https://qiita.com/ko1nksm/items/cea7e7cfdc9e25432bab
args=`getopt -o p: -l port: -- "$@"`

if [ $? != 0 ]; then
    echo "Usage: $0 [-p port | --port port] " 1>&2
    exit 1
fi
#set -- $args
eval "set -- $args"
for OPT in "$@"
do
    case $OPT in
        -u | --user) USER_NAME=$2
            shift 2
            ;;
        -p | --port) PORT_USING=$2
            shift 2
            ;;
        --) shift
            break
            ;;
    esac
done

# docker run
# docker-composeと異なり、相対パスは使えないので注意(絶対パスに変換する)
# https://qiita.com/KentoDodo/items/24117025924d64998110
docker run \
        --name jupyter_conda_custom_amazoncorretto8_${PORT_USING} \
        -d \
        -p ${PORT_USING}:8888 \
        -p 4050:4040 \
        -v $PWD/.jupyter:/home/${USER_NAME}/.jupyter \
        -v $PWD/_work:/home/${USER_NAME}/work \
        -v $PWD/notebook-ssl:/etc/ssl/notebook \
        -v $PWD/spark-defaults.conf:/usr/local/spark/conf/spark-defaults.conf \
        -v $PWD/matplotlibrc:/opt/conda/lib/python3.7/site-packages/matplotlib/mpl-data/matplotlibrc \
        jupyter_conda_custom_amazoncorretto8 \
        jupyter lab --ip=0.0.0.0 --NotebookApp.password='sha1:b735ed4a0d00:75a18f79e312559cd0a266bac3974efb0382775a'  --NotebookApp.keyfile=/etc/ssl/notebook/notebook.key    --NotebookApp.certfile=/etc/ssl/notebook/notebook.crt


#       -v $PWD/bashrc:/home/jovyan/.bashrc \
