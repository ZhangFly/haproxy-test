#!/bin/bash

if [ -z $ETCD_HOST ]; then
	ETCD_HOST="zhangfly.xin"
fi

if [ -z $ETCD_PREFIX ]; then
	ETCD_PREFIX="servers"
fi

if [ -z $PORT ]; then
	PORT="5150"
fi

if [ -z $IP ]; then
	IP=`curl -s whatismyip.akamai.com`
fi

echo "Launching mui-server on $IP and mapped port $PORT to ..."

docker swarm join \
	--token SWMTKN-1-00miqoht4aq3mbeojbu0u22sxe4i32rg1xtsns38jpvhiatifw-agrhwu3wkn96d4yjqvo70flol \
	$ETCD_HOST:2377
		
sleep 1
NAME=`docker ps |grep mui-server |awk '{print $1}'`
	
echo "Announcing to $ETCD_HOST..."
args="http://$ETCD_HOST:2379/v2/keys/$ETCD_PREFIX/$NAME -d value=$IP:$PORT"
curl -XPUT $args

echo "mui-server running on Port $PORT with name $NAME"