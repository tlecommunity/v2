---
title: 'Introduction to the TLE API'
date: 2022-10-31
type: 'page'
---

This document can introduce you to interacting with the Lacuna Expanse game server.

# SERVERS

The list of playable servers can be read from [http://www.lacunaexpanse.com/servers.json](http://www.lacunaexpanse.com/servers.json).

```json
[
  {
    "name": "US1",
    "uri": "https://us1.lacunaexpanse.com/",
    "status": "Open",
    "location": "Texas, United States",
    "type": "Empire Server",
    "description": "Long term empire building, with focus on exploration, trade and malevolent AI."
  }
]
```

Each server in this list is an instance of the game, an individual universe
separated from the others. Your app will need to allow users to select which
server they want to interact with from this list.

# JSON-RPC

The Lacuna Expanse uses a JSON-RPC 2.0 based API. You can read more about
JSON-RPC 2.0 at [http://www.jsonrpc.org/specification](http://www.jsonrpc.org/specification).

You can access these methods either as HTTP POSTs or GETs.

## HTTP GET

Many of the methods can be accessed using an HTTP GET request. Here's an
example URL:

    https://game.lacunaexpanse.com/empire?jsonrpc=2.0&id=1&method=is_name_available&params=["Lacuna Expanse Corp"]

The `https://game.lacunaexpanse.com/` part gets you to the server.

Then `/empire` lets you interact with the [Empire](/api/Empire) module. See below for a
complete list.

To make it JSON-RPC 2.0 compatible, you must include the `jsonrpc=2.0&id=1`
part.

Then specify the method you wish to call with `method=is_name_available`.

And finally pass in whatever parameters you need like
`params=["Lacuna Expanse Corp"]`. Parameters need to be encoded in JSON.
Most requests now require a hash reference of parameters, this would look
like `params={"this":"that","foo":"bar"}`

**NOTE:** You must URL encode the params. If you don't, you'll get a parse
error from the server.

## HTTP POST

Most programming languages will have a JSON-RPC 2.0 client you can either use
directly, or download from the internet. These will use HTTP POST. If you
need to manually create a POST, it would look like:

    POST https://game.lacunaexpanse.com/species

```json
{
  "jsonrpc": "2.0",
  "id": 1,
  "method": "is_name_available",
  "params": ["Human"]
}
```

**NOTE:** It's important to make the distinction here that when you're sending
a POST, you're not sending URL parameters. You're sending a full POST body.
If you format it with parameters like a GET request you'll get a parse error
in response.

### Use Post When Possible

HTTP POST is the preferred method of execution. The reasons for this are:

- You can make multiple method calls in the same request, per the JSON-RPC 2.0
  specification.
- Depending upon the HTTP Client, you'll have somewhere between 512 and 2048
  bytes to send the request on a GET, but it can be unlimited on a POST.
- If you use an HTTP GET, you'll need to URL Encode the params, but with POST
  you don't need to do that.

## Response

Either way you'll get a response back with either a result or an error message.

### Result

If you make a successful request you'll get a response like:

```json
{
  "jsonrpc": "2.0",
  "id": 1,
  "result": 0
}
```

### Error

If an exception is thrown you'll get an error response. It's a hash containing
a code, message, and data section.

```json
{
  "jsonrpc": "2.0",
  "id": 1,
  "error": {
    "code": 1000,
    "message": "Name not available.",
    "data": null
  }
}
```

**NOTE:** If you get a JSON-RPC error, then the web server will also give you a
500 HTTP error code.

## Named parameter requests

Starting in Version 4.000 of the server code, named arguments have been
introduced. The use of positional arguments is no longer supported.

As an example, the following is a call to the shipyard API to find out what
fleets are buildable using both the original positional arguments and the
new named argument calling conventions.

### original positional calling convention (no longer supported)

```json
{
  "jsonrpc": "2.0",
  "id": 1,
  "method": "get_buildable",
  "params": ["329da49c-7e88-4897-9d8c-3e5f6309d9b7", "127894", "Trade"]
}
```

This method is no longer supported. It is shown in case you have any scripts
which need to be modified and for comparison with the following.

### new named argument calling convention

```json
{
  "jsonrpc": "2.0",
  "id": 1,
  "method": "get_buildable",
  "params": {
    "session_id": "329da49c-7e88-4897-9d8c-3e5f6309d9b7",
    "tag": "Trade",
    "building_id": "127894"
  }
}
```

Parameters are named and can be in any order, if a parameter is optional, then
just don't include it. This convention allows future enhancements to methods
without breaking backwards compatibility or having long lists of fixed place
arguments.

## Date Format

As of Version 4.00 the date format has changed.

### original date format (no longer supported)

```
    "MM DD YYYY hh:mm:ss +zone"
    e.g.
    "01 31 2013 13:15:59 +0000"
```

This has been discontinued due to ambiguity of dates such as 7th Apr 2013 which
was previously "04 07 2013" and in most parts of the world would be interpreted
as 4th July 2013.

### New date format

```
    "YYYY MM DD hh:mm:ss +zone"
    e.g.
    "2013 01 31 13:15:59 +0000"
```

This format is unambiguous in all parts of the world.

## RPC Limit

You may only make a number of calls up to the RPC Limit in a given 24 hour
period. The current limit is 10,000 on us1. They are also rate limited to 60
calls per minute on us1. The counter resets roughly (give or take 60 minutes)
at midnight GMT. Your RPC calls are counted across all clients you use and
your own programs.

If you find yourself needing more RPC calls than the limit allows then you are
likely making a lot of redundant requests. For example body.get_buildings()
returns the entire list of buildings, and a time as to when their stats will
change. So instead of calling every building on every planet every time your
program looks something up, cache it until it changes.

# Status

Most methods will provide a status block as part of the response. This is used
to update the user interface and alert the user to things. The status block
looks like this:

```json
{
  /* ... */
  "status": {
    "server": {
      "time": "01 31 2010 13:09:05 +0600",
      "version": 2.0604,
      "announcement": 1, // see the Announcement API
      "rpc_limit": 2500, // max calls per day, compare to empire rpc_count
      "star_map_size": {
        "x": [-15, 15],
        "y": [-15, 15],
        "z": [-15, 15]
      }
    },
    "empire": {
      // this block is not always included
      // See get_status() in Empire
    },
    "body": {
      // this block is not always included
      // See get_status() in Body
    }
  }
}
```

Methods using the 'hash of named parameters' method can specify a 'no_status : 1'
argument which will inhibit the return of a status block. This can be slightly
more efficient for those cases where you don't care to check the status so often.

# Modules

- [ErrorCodes](/api/error-codes)

  A list of the error codes that might be returned by various modules.

- [ApiKeys](/api/api-keys)

  You'll need a key to use the API.

- [Empire](/api/empire)

  Methods for account and empire management.

- [Alliance](/api/alliance)

  Methods for public alliance data.

- [Inbox](/api/inbox)

  Methods for message management.

- [Stats](/api/stats)

  Methods for game server statistics.

- [Map](/api/map)

  Methods for interacting with the star and systems maps.

- [Body](/api/body)

  Methods for interacting with planets and other stellar bodies.

- [Buildings](/api/buildings)

  Methods for interacting with the buildings on a body.

- [Payments](/api/payments)

  How to allow users to purchase Essentia from your app.

- [Announcement](/api/announcement)

  Display a serverwide announcement.

- [Captcha](/api/captcha)

  Request and solve CAPTCHAs
