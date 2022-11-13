---
date: 2022-10-31
type: 'page'
---

# Observatory Methods

Observatory is accessible via the URL `/observatory`.

The observatory controls stellar probes.

The list of methods below represents changes and additions to the methods that all [Buildings](/api/Buildings) share.

## get_probed_stars ( session_id, building_id, [ page_number ] )

Returns a list of the stars that have been probed by this planet.

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
           ],
       "star_count" : 37,
       "max_probes" : 90,
       "travelling" : 2
    }
```

### session_id

A session id.

### building_id

The unique id for the observatory.

### page_number.

An integer representing which set of probes to return. Defaults to 1. Each page has up to 25 probes.

## abandon_probe ( session_id, building_id, star_id )

The probe is deactivated, and allowed to burn up in the star.

```json
{
  "status": {
    /* ... */
  }
}
```

Throws 1002, 1010.

### session_id

A session id.

### building_id

The unique id for the observatory.

### star_id

The unique id of the star the probe is attached to.

## abandon_all_probes ( session_id, building_id )

All probes controlled by this observatory are deactivated,
and allowed to burn up in the stars.

```json
{
  "status": {
    /* ... */
  }
}
```

Throws 1010.

### session_id

A session id.

### building_id

The unique id for the observatory.

```

```
