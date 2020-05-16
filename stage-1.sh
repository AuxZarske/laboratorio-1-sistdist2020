#!/bin/bash

set - e

echo "Bienvenid@ al stage 1"
echo 
echo "3 nodos, 0.5 Hz cada uno"
echo

existNetwork=$(docker network ls --format {{.Name}} | grep red_tcp_g10)
if [ "$existNetwork" != "red_tcp_g10" ]; then
    #crear red
    echo "creando red...⌛"
    docker network create red_tcp_g10
    echo "red creada!👌"
fi

# ejecutar servidor
docker run --rm --network red_tcp_g10 --name server_tcp_g10 -v $PWD/logs:/logs/ servidor_tcp_g10 8000 &

# Esperar 3 seg para asegurar que el servidor arranque
sleep 3

# ejecutar nodos
docker run --rm --network red_tcp_g10 cliente_tcp_g10 node1 0.5 server_tcp_g10 8000 &
pid_node1=$!
docker run --rm --network red_tcp_g10 cliente_tcp_g10 node2 0.5 server_tcp_g10 8000 &
pid_node2=$!
docker run --rm --network red_tcp_g10 cliente_tcp_g10 node3 0.5 server_tcp_g10 8000 &
pid_node3=$!

wait $pid_node1
wait $pid_node2
wait $pid_node3
echo "Apagando servidor...⌛"
docker stop server_tcp_g10
echo "Servidor apagado!👌"
# borrar red
echo "Borrando red...⌛"
docker network rm red_tcp_g10
echo "Red eliminada!👌"