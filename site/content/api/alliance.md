---
date: 2022-10-31
type: 'page'
---

# Alliance Management

If you are looking for the methods to manage an alliance, they can be found in the [Embassy](/api/Embassy).

# Alliance Methods

The following methods are available from `/alliance`.

## view_profile

Provides a list of the data that's publicly known about this alliance.

Accepts either fixed arguments or a hash of named parameters

    ( session_id, alliance_id )
    ( parameter_hash )

Throws 1002

### session_id

A session id.

### alliance_id

The id of the alliance you want to obtain data on.

```json
{
  "profile": {
    "id": "id-goes-here",
    "name": "Lacuna Expanse Allies",
    "description": "Blah blah blah blah...",
    "leader_id": "id-goes-here",
    "date_created": "01 31 2010 13:09:05 +0600",
    "members": [
      {
        "id": "id-goes-here",
        "name": "Lacuna Expanse Corp"
      }
      /* ... */
    ],
    "space_stations": [
      {
        "id": "id-goes-here",
        "name": "The Life Star",
        "x": -342,
        "y": 128
      }
      /* ... */
    ],
    "influence": 0
  },
  "status": {
    /* ... */
  }
}
```

## find ( session_id, name )

Find an alliance by name. Returns a hash reference containing alliance ids and alliance names.

Accepts either fixed arguments or a hash of named parameters

    ( session_id, name )
    ( parameter_hash )

### session_id

A session id.

### name

The name you are searching for. It's case insensitive, and partial names work fine. Must be at least 3 characters.

### RESPONSE

So if you searched for "Lacuna" you might get back a result set that looks like this:

```json
{
  "alliances": [
    {
      "id": "id-goes-here",
      "name": "Lacuna Expanse Allies"
    },
    {
      "id": "id-goes-here2",
      "name": "Lacuna Pirates"
    }
  ],
  "status": {
    /* ... */
  }
}
```
