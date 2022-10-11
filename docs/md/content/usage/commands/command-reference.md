---
layout: page
title: Command reference
description: List of useful Litmus commands.
---

### Debug

Litmus has the ability to display more information when it is running, this can help you diagnose some issues. 

```
export DEBUG=true
```

### Useful Docker commands

To list all docker images, including stopped ones, run:
```
docker ps -a
```

You will get output similar to:

```
docker container ls -a
CONTAINER ID        IMAGE                      COMMAND                  CREATED              STATUS                     PORTS                  NAMES
e7bc7e5b3d9b        litmusimage/oraclelinux7   "/bin/sh -c /usr/sbi…"   About a minute ago   Up About a minute          0.0.0.0:2225->22/tcp   litmusimage_oraclelinux7_-2225
ae94def06077        litmusimage/oraclelinux6   "/bin/sh -c /sbin/in…"   3 minutes ago        Up 3 minutes               0.0.0.0:2224->22/tcp   litmusimage_oraclelinux6_-2224
80b22735494e        litmusimage/centos6        "/bin/sh -c /sbin/in…"   5 minutes ago        Up 5 minutes               0.0.0.0:2223->22/tcp   litmusimage_centos6_-2223
b7923a25f95b        ubuntu:14.04               "/bin/bash"              6 weeks ago          Exited (255) 4 weeks ago   0.0.0.0:2222->22/tcp   ubuntu_14.04-2222
```

To stop and remove an image, run:

```
docker rm -f ubuntu_14.04-2222
```

To connect via ssh to the Docker image, run:

```
ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no root@localhost -p 2222
```

Note that you don't need to add to the known hosts file or check keys.

To attach to the docker image and detach, run:

```
docker attach centos6
 to deattach <ctrl + p> then <ctrl + q>
```

Note that you cannot attach to a Docker image that is running systemd/upstart, for example, the `litmus_image` images.
