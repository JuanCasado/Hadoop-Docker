
UP="up"
DOWN="down"
DEPLOY="deploy"
ACTION="$1"

# Check if it is a valid call
if [ -z ${ACTION} ] || [ ${ACTION} == "-h" ] ||[ ${ACTION} == "--help" ]; then
  echo "Call $0 with ${UP} or ${DOWN} options"
  exit 1
fi

# SWARM configuration
MASTER="master"
WORKER="worker"
WEB_PORT="8080"
REGISTRY="swarm-docker-registry.com"
WORKER_COUNT=2
WORKERS=()
NODES=(${MASTER})
for ((i=1; i<=${WORKER_COUNT}; ++i)); do
  WORKERS[${#WORKERS[@]}]="${WORKER}-${i}"
done
NODES[${#NODES[@]}]=${WORKERS[@]}

# FUNCTIONS DECLARATION

map () {
  FUNCTION=$1;shift;
  echo "Apply: ${FUNCTION} <NODE>"
  for value in $@; do
    echo "To: ${value}"
    ${FUNCTION} "${value}"
  done
}

mapT () {
  FUNCTION=$1;shift;
  TRAIL=$1;shift;
  echo "Apply: ${FUNCTION} <NODE> ${TRAIL}"
  for value in $@; do
    echo "To: ${value}"
    ${FUNCTION} "${value}" \
    "${TRAIL}"
  done
}

mapPS () {
  FUNCTION=$1;shift;
  PREFIX=$1;shift;
  SUFIX=$1;shift;
  echo "Apply: ${FUNCTION} ${PREFIX}<NODE>${SUFIX}"
  for value in $@; do
    echo "To: ${value}"
    ${FUNCTION} "${PREFIX}" "${value}${SUFIX}"
  done
}

if [ "$1" == "${UP}" ]; then
  echo "Creating SWARM with ${MASTER} and ${WORKER} from 1 to ${WORKER_COUNT}"

  map "docker-machine create" ${NODES[@]}
  MASTER_IP=$(docker-machine ls | awk '{if(NR==2) print $5}' | cut -d':' -f2 | cut -c3-)
  JOIN=$(docker-machine ssh ${MASTER} docker swarm init --advertise-addr ${MASTER_IP} | awk '{if(NR==5) print}' | cut -c5-)
  mapT "docker-machine ssh" "${JOIN}" ${WORKERS[@]}
  eval $(docker-machine env ${MASTER})

  # MACHINE VISUALIZER
  docker service create \
    --name=viz \
    --publish=${WEB_PORT}:8080 \
    --constraint=node.role==manager \
    --mount=type=bind,src=/var/run/docker.sock,dst=/var/run/docker.sock \
    dockersamples/visualizer
  open "http://${MASTER_IP}:${WEB_PORT}"

  # SETUP NAME REGISTRY
  openssl req -newkey rsa:4096 -nodes -sha256 \
    -keyout registry.key -x509 -days 365 \
    -subj "/CN=${REGISTRY}/O=mrblissfulgrin/C=SP" \
    -out registry.crt
  mapPS "docker-machine scp" "registry.crt" ":/home/docker/" ${NODES[@]}
  mapT "docker-machine ssh" "sudo mkdir -p /etc/docker/certs.d/${REGISTRY}:5000" ${NODES[@]}
  mapT "docker-machine ssh" "sudo mv /home/docker/registry.crt /etc/docker/certs.d/${REGISTRY}:5000/ca.crt" ${NODES[@]}
  mapT "docker-machine ssh" "sudo sh -c \"echo '${MASTER_IP} ${REGISTRY}' >> /etc/hosts;exit\"" ${NODES[@]}
  docker-machine scp registry.crt ${MASTER}:/home/docker/
  docker-machine scp registry.key ${MASTER}:/home/docker/
  docker service create --name registry --publish=5000:5000 \
    --constraint=node.role==manager \
    --mount=type=bind,src=/home/docker,dst=/certs \
    -e REGISTRY_HTTP_ADDR=0.0.0.0:5000 \
    -e REGISTRY_HTTP_TLS_CERTIFICATE=/certs/registry.crt \
    -e REGISTRY_HTTP_TLS_KEY=/certs/registry.key \
    registry:latest

  # Deploy hadoop
  docker build hadoop-base -t ${REGISTRY}:5000/hadoop-base:latest
  docker push ${REGISTRY}:5000/hadoop-base:latest
  docker-compose -f ./docker-compose-swarm.yml build
  docker-compose -f ./docker-compose-swarm.yml push
  docker stack deploy -c docker-compose-deploy.yml hadoop

  echo "Master IP: ${MASTER_IP}"
  echo "Join Swarm: ${JOIN}"
fi

if [ "$1" == "${DOWN}" ]; then
  echo "Deleting SWARM with ${MASTER} and ${WORKER} from 1 to ${WORKER_COUNT}"

  eval $(docker-machine env ${MASTER})
  docker stack rm hadoop
  docker service rm registry
  docker service rm viz
  mapT "docker-machine ssh" "docker swarm leave --force" ${NODES[@]}
  map "docker-machine rm" ${NODES[@]}
  docker swarm leave --force
fi
