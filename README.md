# Akamai Docker Image

Environment setup for Akamai Docker:

- Akamai CLI and all modules available
- Terraform + Akamai provider
- curl and httpie with EdgeGrid addons

## How to use it

To create a new environment:

```
docker run -it --name akamai akamai/akamai-docker
```

To return to already created environment:

```
docker start -i akamai
```

## Authentication

The standard authentication method for most Akamai APIs is called EdgeGrid. Creating an EdgeGrid client is covered on [developer.akamai.com](https://developer.akamai.com/api/getting-started).

You will typically create an `.edgerc` file in your home directory with contents similar to this:

```ini
[default]
client_secret = your_client_secret
host = your_host
access_token = your_access_token
client_token = your_client_token
```

We recommend mounting this file directly into your containers; the following example illustrates this by verifying the credentials from within a container:

```
docker run -it --name akamai akamai/akamai-docker -v "~/.edgerc:/root/.edgerc:ro" akamai auth verify
```

### Sandbox

> *Note: Credits go to Nick Le Mouton for his awesome blog post: <https://www.noodles.net.nz/2018/10/12/running-akamai-sandbox-in-docker-with-https/>*

Assuming you run a webserver locally on port 5000 and sandbox is exposed on port 9550:

- ensure you run docker with port mapping:
  ```
  docker run -it -p 9550:9550 --name mylab akamai/akamai-docker
  ```

- set up sandbox client to listen on address `0.0.0.0`:
  ```
  "sandboxServerInfo": {
    "secure": false,
    "port": 9550,
    "host": "0.0.0.0"
  },
  ```

- setup origin mapping using a special docker hostname:
  ```
  "originMappings": [
    {
      "from": "",
      "to": {
        "secure": false,
        "port": 5000,
        "host": "host.docker.internal"
      }
    }
  ],
  ```

### non-interactive sessions

The above use case assumes that user starts bash sessions and invokes commands inside of it. However, it's also possible to use this docker image to execute commands straight like on the following example:

```
❯ docker run -it --rm -p 9550:9550 -v $HOME/.edgerc:/root/.edgerc -v $(pwd)/sandbox:/cli/.akamai-cli/cache/sandbox-cli akamai/akamai-docker akamai sandbox list
Local sandboxes:

current  name      sandbox_id
-------  --------  ------------------------------------
YES      username  11111111-222-3333-4444-555555555555
```

This way, the container is immediately removed when the execution is complete. You can use path mount - like in the example above - to persist state across multiple commands invocations. The example above stores *sandbox-cli* local data in `$(pwd)/sandbox` subfolder so it's possible to operate on the same sandbox like in a single bash session.

## Build

Builds are automated via the scripts in the [scripts](scripts) directory.

Just building locally can be accomplished by calling:

```bash
docker build -t akamai-docker .
```

## License
Copyright 2020 Akamai Technologies, Inc.

See [Apache License 2.0](LICENSE)

By submitting a contribution (the “Contribution”) to this project, and for good and valuable consideration, the receipt and sufficiency of which are hereby acknowledged, you (the “Assignor”) irrevocably convey, transfer, and assign the Contribution to the owner of the repository (the “Assignee”), and the Assignee hereby accepts, all of your right, title, and interest in and to the Contribution along with all associated copyrights, copyright registrations, and/or applications for registration and all issuances, extensions and renewals thereof (collectively, the “Assigned Copyrights”). You also assign all of your rights of any kind whatsoever accruing under the Assigned Copyrights provided by applicable law of any jurisdiction, by international treaties and conventions and otherwise throughout the world.
