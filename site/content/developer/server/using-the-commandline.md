---
date: 2022-10-31
type: 'page'
---

When using Lacuna from the server, there are some things you may want to do
that may not be obvious.  This should help with some common aspects
whether you're using the full server, or the dockerized version.


In all places that can take 'Your Account', your ID can be used as well.
On a private server, that will usually be 2 since Lacuna Expanse Corp should
be 1.

1. Create your admin account.

  a) Start by creating the account as usual - the easiest way is
through the web client.

  b) Once you've created it, you need to run the following command
(inside the docker container if you're using docker, using
connect_server.sh):

    perl -I/home/lacuna/server/lib -ML -E '$e = LD->empire(shift)->is_admin(1); $e->update' 'Your Account'

  You can obviously create extra admin accounts, but that's not usually
  going to be too useful.


2. Connect to the admin UI

  a) Add "/admin" to the end of the URL, e.g., http://my.tlecommunity.com/admin

  Be sure you already have an admin account (see above).


3. How to reset your password

  a) Run (inside docker) the following command:

    perl -I/home/lacuna/server/lib -ML -E 'LD->empire(shift)->set_password(shift)' 'Your Account' 'newpassword'


4. How to reset your RPCs

  a) Run (inside docker) the following command:

    perl -I/home/lacuna/server/lib -ML -E 'LD->empire(shift)->reset_rpcs' 'Your Account'


5. How to call a web API from the command line

  a) Run (inside docker) the following command:

    perl -I/home/lacuna/server/lib -ML -E 'LR->call(Type => method => <params>)'

  where Type is, for example, "Empire" or "SpacePort", method is the name
  of the API, and then the parameters.  Most APIs require a session ID, but
  the session ID can be faked by passing in an empire object with:
  LD->empire("Empire Name or Number") - this will work whether the session
  ID is the first parameter (usually) or is in the session_id key of a hash
  reference (sometimes).

  This will, much like the log files, show the request (input) data and
  the response (output) data on the output.  You may want to pipe this
  through less or some such.

  Alternatively, use jcall instead of call to get the output in JSON
  instead of in perl's dumper format.

  If you are looking to debug an API, you can use this, but just change
  -E to -dE, and the debugger will come up, and you can step through it
  normally.

  Each call will start its own session, which makes captchas impossible
  to fill out here.  If you set captcha to a true value in the environment,
  the LR module will automatically fake a captcha for testing purposes.
  For example:

    captcha=1 perl -I/home/lacuna/server/lib ...

  This faked captcha will only be valid for this one run of the code,
  and will not impact the captcha of multiple runs, making it easy to
  run both with and without a captcha in subsequent tests.
