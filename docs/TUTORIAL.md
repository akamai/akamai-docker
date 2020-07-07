# Akamai Docker Development Environment Tutorial

This document provides examples on using the different packages, and more explanations for those not so familiar with Docker.

## Starting Docker Containers for interactive use

Using [`docker run`](https://docs.docker.com/engine/reference/run/) you can start an isolated docker container out of a docker image. There are several ways to use docker containers, for example:

### Permanent container (keep the session alive)

You would start the container using `docker run` , than you add `-it` to indicate interactive, followed by `--name` and a name of your choice to be able to refer to that container later on easily.

The example below creates a docker container named `akadev` out of the docker image `shell` within the organization `akamai`:

```bash
docker run -it --name akadev akamai/shell
```

You can then exit the container, and start it later on using:

```bash
docker start -i akadev
```

The files inside this docker container will persist in the host machine until the container is destroyed using `docker rm`. Once you remove the container using `docker rm` all the files inside will be lost.

### Permanent container (fresh session each time) 

Sometimes you want to start a container fresh each time (without any leftover files from previous sessions). To do that, you would start the container using `docker run` , than you add `-it` to indicate interactive, followed by `--rm` to indicate the container should be removed upon exit. When using fresh containers, it is often very useful to mount one or more files (or a folders) from the host system into the container, like for example to mount the file .edgerc containing the Akamai OPEN API client credentials

The example below creates a docker container out of the docker image `shell` within the organization `akamai`, that will be cleaned up `--rm` and mounts the `$HOME/.edgerc` file from the host machine into `/root/.edgerc` in the container as read-only:

```bash
docker run --rm -it -v $HOME/.edgerc:/root/.edgerc:ro akamai/shell
```

Note: Notice in the above example we are not giving the docker container a name using `--name`, in that case docker will assign a random name that you can see running a `docker ps` command.

Another way to achieve the same result would be to first create a container using the command below:

```bash
docker run --rm -it -v $HOME/.edgerc:/root/.edgerc:ro akamai/shell
```

And then in another terminal window, run a `docker ps` to identify the docker container name (determined_borg in our example), and then copy the `$HOME/.edgerc` file into the container using`docker cp`:

```bash
docker ps
CONTAINER ID        IMAGE               COMMAND                  CREATED             STATUS              PORTS               NAMES
c5ec1eadf45f        akamai/shell        "/bin/bash -lc '${0}…"   11 seconds ago      Up 10 seconds                           determined_borg

docker cp $HOME/.edgerc determined_borg:/root/.edgerc
```
