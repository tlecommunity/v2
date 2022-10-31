---
date: 2022-10-31
type: 'page'
---

# Oracle of Anid Methods

Oracle of Anid is accessible via the URL `/oracleofanid`.

The list of methods below represents changes and additions to the methods that all [Buildings](/api/Buildings) share.

## get_star (session_id, building_id, star_id)

Retrieves info on a single star. Works like ["get_star" in Map](/api/Map#get_star) except that you can see the bodies even if there is no probe there. Therefore the same displays that you would have for the star and these bodies in the star map should work from this interface. Send a scow to a star, attack a player, send a mining platform, etc.

There is a range to the Oracle based upon it's level. A 10 map unit radius per level. A 1009 exception will be thrown if you request a star that its outside that range.

**NOTE: Use ["search_stars" in Map](/api/Map#search_stars) to look up the id of a star by name.**

```json
    {
       "star" : {
           "name"          : "Sol",
           "color"         : "yellow",
           "x"             : -41,
           "y"             : 27,
           "bodies"        : [
               {
                   same data as get_status() on /body
               },
               /* ... */
           ]
       }
       "status" : { /* ... */ }
    }
```

### session_id

A session id.

### building_id

The unique id of the Oracle.

### star_id

The unique id of the star.

## get_probed_stars

Returns all stars that are within distance of the Oracle

Uses named arguments call

```json
{
  "session_id": "session-goes-here",
  "building_id": "building-id-goes-here",
  "page_number": 1
}
```

### session_id (required)

The session ID

### building_id (required)

The ID of the Oracle building

### page_number (optional)

The page number of the results, defaults to page 1 where each page contains **page_size** records.

### page_size (optional)

Defaults to a page size of 25, can have any value from 1 to 200

### RESPONSE

```json
    {
       "status" : { /* ... */ },
       "stars" : [
           "id" : "id-goes-here",
           "color" : "yellow",
           "name" : "Sol",
           "x" : 17,
           "y" : 4,
           "z" : -3,
           "bodies" : [
               { See get_status() in Body },
               /* ... */
           ]
       ,
       "star_count" : 5,
       "max_distance" : 10,
    }
```
