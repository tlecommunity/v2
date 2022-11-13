---
date: 2022-10-31
type: 'page'
title: 'Docker Setup'
---

Docker documentation can be found [here](https://docs.docker.com).

Docker works with containers which you can think of as lightweight
virtual machines. They can be built once, and deployed in many places.

To provide some context: if you were to set up a server from scratch, you would
need to do so either on a Linux server, or a virtual machine running
Centos. You would need to install all the packages, including building
Perl and loading all the support libraries and CPAN modules. From
experience this can take up to 16 hours to do and to resolve any issues. By comparison, setting up the Docker stuff takes far less time and energy - I estimate maybe an hour or two.

## 1. Install Docker

Installation on various systems can be found [here](https://docs.docker.com/engine/installation/).

Please check the requirements. In particular on Windows you need to
ensure that your PC supports virtualization technology and that it
is enabled in the BIOS.

Docker comes with a tool called [Compose](https://docs.docker.com/compose/), which is the main interface we will interact with to
bring up the database, backend, frontend etc.

## 2. Build the Containers

```bash
# In the root of the repo:
docker compose build
```

This command may take quite a while, especially on first run.
It depends on the speed of your internet connection.

## 3. Start Everything

We can now start up the entire server and its dependencies. When doing development work, this is the command to use.

```bash
# In the root of the repo:
docker compose up
```

As this is your first time running the whole mess, expect a whole bunch of images to be downloaded as well as the backend server failing to start due to the game not being initialized.
We'll now take care of that in the next step.

## 4. Setup Database

Let's now initialize the database and generate the starmap

```bash
# You can do this both with or without `docker compose up` running in another window.
# Compose handles bringing up the services it needs.

# In the repo root:
docker compose run server /bin/bash

cd /home/lacuna/server/bin/setup
perl init-lacuna.pl
```

This process will take a while depending on the speed of your machine.

## 5. Finishing Up

You should now be able to bring up the whole environment (`docker compose up`) and play the game.

## Services Reference

The following web services are available once everything has been set up and started by Compose:

|                 Service                 |         Description          |
| :-------------------------------------: | :--------------------------: |
| [localhost:2000](http://localhost:2000) |    Documentation website     |
| [localhost:2080](http://localhost:2080) |   Background jobs console    |
| [localhost:3000](http://localhost:3000) |       Frontend client        |
| [localhost:3001](http://localhost:3001) |     Stubbed test server      |
| [localhost:3002](http://localhost:3002) |        Assets server         |
| [localhost:5000](http://localhost:5000) |     Perl backend server      |
| [localhost:8000](http://localhost:8000) | phpMyAdmin for db visibility |
| [localhost:8080](http://localhost:8080) |         Nginx server         |

## Connecting to the Database

Once you have `docker compose up` running, connecting to the server and doing whatever database manipulation you desire is simple.

```bash
# Open another terminal and `cd` into the repo root.
./connect-mysql.sh
```

You should now be logged into the database. To test, you can run `select name from empire;` which will output a list of empire's names.

## Connecting to the Server

If there's something you need to run on the server, here's how you do it...

Once you have `docker compose up` running do the following:

```bash
# Open another terminal and `cd` into the repo root.
./connect-server.sh
```

## Making Changes to the Code

Code changes should be made outside the Docker containers (aka, on the host machine). The `lib`, `bin`, `etc`, and `var` are all made accessible inside the server container for them to work.
When making code changes, plackup will watch for changes and reload automatically.
However if this doesn't happen or seems to have frozen (it _is_ slow unfortunately, I think mostly due to Docker file system limitations) try killing the command and restarting everything.
