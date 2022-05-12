[hub]: https://hub.docker.com/r/ntr001/fivem
[git]: https://github.com/ntr001/fivem
# [ntr001/fivem][hub]

This docker image allows you to run a server for [FiveM](https://fivem.net/), a modded GTA multiplayer application. This image also includes [txAdmin](https://github.com/tabarra/txAdmin), an in-browser server management software.
Upon first run, the default configuration is generated in the host mount for the `/txData` or `/config` directory depending on which run mode has been selected by docker container parameters.
In case the container has been deployed without txAdmin support, then upon first run it should be stopped so FiveM can be configured to the user requirements in the `server.cfg`.

## About

The other docker images available on Docker Hub are based on (really) outdated FiveM versions, so I decided to start maintaining a FiveM docker image on my own, as I would like to keep it as up-to-date as possible. I'll keep an eye on [FiveM's official linux runtime repository](https://runtime.fivem.net/artifacts/fivem/build_proot_linux/master/) and this docker image will be kept updated to LATEST RECOMMENDED version. There is a monitoring solution implemented already which sends an alert when a new recommended version is available, and I'm in the middle of implementing an automated CI/CD solution, so automated docker container solutions, like [pyouroboros/ouroboros](pyouroboros/ouroboros), will keep it up-to-date effortlessly.

## License Key

A freely obtained license key is required to use this server, which should be declared as `$LICENSE_KEY` environment parameter. A tutorial on how to obtain a license key can be found [here](https://forum.fivem.net/t/explained-how-to-make-add-a-server-key/56120).

## Usage

Use the `docker-compose` script provided if you wish to run a [CouchDB](https://couchdb.apache.org/) server with FiveM, otherwise use one of the docker run commands below.

_It is important that you use `interactive` and `pseudo-tty` options otherwise the container will crash on startup_
See [issue #3](https://github.com/spritsail/fivem/issues/3)

### FiveM with txAdmin

```sh
docker run -d \
  --name FiveM \
  --restart=unless-stopped \
  -e LICENSE_KEY=<your-license-here> \
  -p 30120:30120 \
  -p 30120:30120/udp \
  -p 40120:40120 \
  -v /volumes/fivem:/txData \
  -ti \
  ntr001/fivem
```

If FiveM container has been deployed with txAdmin support, then the rest of the configuration parameters should be applied using txAdmin interface by navigating to url: http://hostname-or-ip-address:port/

#### Environment Variables for FiveM with txAdmin

* `SERVER_PROFILE` - Optional. The name of the server profile to start. Profiles are saved/loaded from the current directory inside the `txData` folder. The default is `default`.
* `TXADMIN_PORT` - Optional. The TCP port to use as HTTP Server. The default is `40120`.

### FiveM without txAdmin

```sh
docker run -d \
  --name FiveM \
  --restart=unless-stopped \
  -e TXADMIN_DISABLE=Y \
  -e LICENSE_KEY=<your-license-here> \
  -p 30120:30120 \
  -p 30120:30120/udp \
  -v /volumes/fivem:/config \
  -ti \
  ntr001/fivem
```

#### Environment Variables for FiveM without txAdmin

* `TXADMIN_DISABLE` - Mandatory. Set to any non-zero value to disable txAdmin framework. In case this parameter is absent, FiveM will start with txAdmin support.
* `LICENSE_KEY` - Mandatory.  The license key needed to start the server.
* `RCON_PASSWORD` - Optional. A password to use for the RCON functionality of the FXServer. If not specified, a random 16 character password is assigned. This is only used upon creation of the default configs during the first run.
* `FIVEM_PORT` - Optional. FiveM server port number for both TCP and UDP protocols. Default value is: 30120
* `SV_HOSTNAME` - Optional. The server-specific host name. Default value is: Default
* `STEAM_WEBAPIKEY` - Optional. Steam Web API key, if you want to use [Steam authentication](https://steamcommunity.com/dev/apikey). Default value is: none
* `ONESYNC` - Optional. Allowed values are [on | legacy | off]. Default value is: on
* `ONESYNC_POPULATION` - Optional. Allowed values are [true | false]. Default value is: true
* `GAME_BUILD` - Optional. Enforces a game build for clients to use. Default value is: 2545

### Docker volume persistent data permission handling

* `PID` - Optional. The UserID of the `fivem` user created inside the container. See below for explanation.
* `PGID` - Optional. The GroupID of the `fivem` group created inside the container. See below for explanation.

#### User / Group Identifiers

When using volumes (`-v` flags) permissions issues can arise between the host OS and the container. This issue could be avoided by providing the user `PUID` and group `PGID` as docker container environment variables. For example:

```sh
docker run -d \
  --name FiveM \
  --restart=unless-stopped \
  -e PID=1000 \
  -e PGID=1000 \
...
```

In this instance `PUID=1000` and `PGID=1000`, which usually belongs to user account which was first created on the host OS. To find these values use `id user` as below:

```sh
  $ id username
    uid=1000(username) gid=1000(usergroup) groups=1000(usergroup)
```

It is important to note that the values of `PID` and `PGID` provided to docker container as environment variables should represent an existing user on the host OS.

On top of that, the persistent data permission handling is implemented as below:

* when `PID` and `PGID` parameters are provided, the entrypoint shell script will create the required files and directories with the ownership of user on host OS with `PID` and `PGID`.
* when `PID` and `PGID` parameters are not provided, and the docker volume is empty, the entrypoint script will create the required files and directories with the ownership of user starting the docker container.
* when `PID` and `PGID` parameters are not provided, and the docker volume contains a `/config` or `/txData` already, the entrypoint script will evaluate the `PID` and `GID` values based on the ownership of existing `/config` or `/txData` directories. Additionally, if the config directory is empty, it will create the required files and directories.

Either way, during each startup event, the entrypoint script will do change ownership for all persistent data entries (files and directories under `/config` or `/txData` volumes) with the evaluated user and group values.

## Credits

 - This image is based on [spritsail/fivem](https://github.com/spritsail/fivem) project. Many thanks for your efforts, [spritsail](https://github.com/spritsail)!
 - Thanks to [Andruida](https://github.com/Andruida) for the concept of the persistent data permission handling in [Andruida/fivem](https://github.com/Andruida/fivem) project!
 - Thanks to [tabarra](https://github.com/tabarra) as the creator and maintainer of the [txAdmin](https://github.com/tabarra/txAdmin) repository!
