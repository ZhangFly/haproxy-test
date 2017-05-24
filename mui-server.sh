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

# 启动docker
function launch_container {
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
}

# 停止docker
function stop_container {
	echo "Stopping mui-server..."
	NAME=`docker ps |grep mui-server |awk '{print $1}'`
	docker swarm leave
	args="http://$ETCD_HOST:2379/v2/keys/$ETCD_PREFIX/$NAME"
	curl -XDELETE $args
	echo "Stopped."
}

if [ -z $1 ]; then
	echo 'usage:'
	echo '    ./mui-server.sh [start|stop]'
else
	if [ $1 = "start" ]; then
		launch_container
	fi
	if [ $1 = "stop" ]; then
		stop_container
	fi
fi