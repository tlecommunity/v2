---
date: 2022-10-31
type: 'page'
---

when using beanstalk, the following needs to be done.

install the following CPAN modules

Beanstalk::Client
App::Daemon

To install beanstalk

$ cd /data/Lacuna-Server-Open/
$ mkdir third_party
$ cd third_party
$ git clone git://github.com/kr/beanstalkd.git
$ cd beanstalkd
$ make
$ make install

add the following in lacuna.conf

    "beanstalk" : {
        "debug" :         0,
        "server" :        "localhost",
        "ttr" :           120,
        "max_timeouts" :  10,
        "max_reserves" :  10
    },

To start beanstalk and to detach

$ beanstalkd >/tmp/beanstalk 2>/tmp/beanstalk < /dev/null & disown

To run the scheduler

$ cd /data/Lacuna-Server-Open/bin
$ perl schedule_daemon.pl
