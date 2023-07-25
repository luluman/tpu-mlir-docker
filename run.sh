function work-linux()
{
  local UID=$(id -u)
  local GID=$(id -g)
  local home=$(realpath ./home)
  local workspace=$(realpath ~/tpumlir-dev)
  local data=$(realpath /data)
  local share=$(realpath /share)
  docker run -t \
         --privileged \
         --name ${USER}-tpumlir-dev \
         --user $UID:$GID \
         --detach-keys "ctrl-^,ctrl-@" \
         --volume="${home}:/home/$USER":delegated \
         --volume="${workspace}:/workspace":cached \
         --volume="${data}:/data":cached \
         --volume="${share}:/share":cached \
         --volume="/etc/group:/etc/group:ro" \
         --volume="/etc/passwd:/etc/passwd:ro" \
         --volume="/etc/shadow:/etc/shadow:ro" \
         --detach \
         mattlu/tpumlir-dev:22.04 /bin/bash
}

function work-linux-attach()
{
  docker attach \
         ${USER}-tpumlir-dev \
         --detach-keys "ctrl-^,ctrl-@"
}

function work-linux-exec()
{
  docker exec -ti \
         --detach-keys "ctrl-^,ctrl-@" \
         ${USER}-tpumlir-dev /bin/bash

}
