#!/bin/bash

if [ -z $ETCD_HOST ]; then
	ETCD_HOST="zhangfly.xin"
fi

if [ -z $ETCD_PREFIX ]; then
	ETCD_PREFIX="servers"
fi

echo "Stopping mui-server..."
NAME=`docker ps |grep mui-server |awk '{print $1}'`
docker swarm leave
args="http://$ETCD_HOST:2379/v2/keys/$ETCD_PREFIX/$NAME"
curl -XDELETE $args
echo "Stopped."