---
date: 2022-10-31
type: 'page'
---

Step 0: initial requirements.

These instructions assume that you are setting up a server on (for example)
linode.com (a basic 48GB, Linode 2048 is just fine).

If you are not on this environment then you will need to tear apart the
scripts and build it yourself.

Create a CentOS 6.5 disk Image using the defaults.

Then boot your linode and SSH into the system as root.

First thing you should do is create a user account, then remove root login
via SSH. This blocks one main security hole.

  # Create a user account
  [root@myserver /]# useradd icydee
  [root@myserver /]# passwd icydee
  Changing password for user icydee.
  New password:
  Retype new password:
  passwd: all authentication tokens updated successfully.

Remove SSH root login.

  [root@myserver /]# vi /etc/ssh/sshd_config

  # Make sure the following line is uncommented.
  PermitRootLogin no

  # While you are at it, prevent timeouts
  ClientAliveInterval 30
  ClientAliveCountMax 4

  # Now exit and restart SSH
  [root@myserver /]# /etc/init.d/sshd restart

Install a few repos.

  [root@myserver /]# yum install git mysql mysql-devel cpan

Create a directory for the repos and get them

  [root@myserver /]# cd /
  [root@myserver /]# mkdir data
  [root@myserver /]# cd data
  [root@myserver data]# git clone https://github.com/plainblack/Lacuna-Server-Open.git

At this point you *may* need to set up the following, and include it in your
bash profile (it was found to be needed in order to run memcache in certain
circumstances)

  [root@myserver /]# export LD_LIBRARY_PATH=/data/apps/lib

Step 1: Prereqs

First install all the prerequisites. This works on a ContOS/ RHEL environment.

  cd bin/setup/server
  ./download.sh
  ./build.sh
  cd ..
  ./install-pm.sh

If not, then you'll need to tear apart those scripts and do what they do.

At some point in this process, /data/apps/bin should be appended to your path
and put in the bash profile. You may need to log out and back in make this
work correctly.

All of the above will take quite a while, if you suspect a bug, pull the
scripts apart and run them manually one by one looking for errors.

Often, the error is that the script is trying to download a version which is
no longer supported. Check the web sites for the closest version to use.



Step 2: Start Storage

You need to start up your MySQL server, memcached, and beanstalk.


Memcached is as easy as:

memcached -d -u nobody -m 512

For a private server, 512 may be overkill, -m 64, the default, is
likely sufficient.

For beanstalk, see the setup_beanstalk.txt file.  At this point, only
the setup is required, the scheduler is not.


MySQL needs one extra bit of configuration.  In /etc/my.cnf, find the
section labelled "[mysqld]" and add the following line:

  log_bin_trust_function_creators = 1

Starting MySQL will depend on the system and how you installed it.

  # Make sure MySQL service starts on boot
  [root@myserver /]# chkconfig --levels 235 mysqld on

  # Start it
  [root@myserver /]# service mysqld start

Step 3: Config Files

You'll need to create lacuna.conf, nginx.conf, and log4perl.conf in your
Lacuna-Server-Open/etc folder. Templates exist in the etc directory.

Things you must change in lacuna.conf

  "db" settings to match an account in mysql

  Usually it's best to set up a username 'lacuna' in mysql that only has
access to the 'lacuna' database. (see below)

  "map_size" defines the size, a size of -500 to 500 is good enough to test
  with

  Most other things can stay with their default values.

Things to change in log4perl.conf

  Most things in here can be kept as they are, until you start to
  need more debugging options.

Things to change in nginx.conf

  "server_name" should be changed from 'myserver.com' to the domain of your
  server

  Most other things in there can be kept as they are.

Step 4: Initialize Database

Log into mysql and create a database:

mysql -uroot -pyourrootpassword

create database lacuna;
grant all privileges on lacuna.* to lacuna@localhost identified by 'somepassword';
flush privileges;
exit;

cd bin/setup
perl init-lacuna.pl
perl generate_captcha.pl


Step 5: Start The Server

You will need an index.html, this does not come in the code, the best way to
get it is to take it from somewhere like

http://pt.lacunaexpanse.com/index.html

and copy it into the var/www/public directory.

To start the lacuna server just type:

  cd bin
  ./start_nginx.sh        (will start nginx as a daemon)
  ./startdev.sh           (will run the dev server, all output will come to the console)

Now in another terminal you can start issuing commands to the server.



Step 6: Missions (optional)

If you want to be able to do anything with missions, you'll need to check out the Lacuna-Mission repository into
/data/Lacuna-Mission
