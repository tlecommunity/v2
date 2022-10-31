---
date: 2022-10-31
type: 'page'
---

# Map Data

An export of the public map data (ie the Stars), is available to download in an easy to use CSV format. The URL is

    http://gameservername.lacunaexpanse.com.s3.amazonaws.com/stars.csv

So if the server name is "us1", then the the URL would be

    http://us1.lacunaexpanse.com.s3.amazonaws.com/stars.csv

# Map Methods

These methods are accessible via the `/map` URL.

## get_star_map

```json
    {
      "session_id" : "9eea6721-3326-4c1f-817d-a4e82b54818e"
      "left"       : -900,
      "top"        : 50,
      "right"      : -850,
      "bottom"     : 30
    }
```

Where **left**, **top**, **right**, **bottom** represent the sides of the bounding rectangle.

The maximum area that can be returned is 3001 units (e.g 50 x 60 or 3001 x 1)

Returns a chunk of the map as an array of hashes.

```json
    {
      "stars" : [
        {
          "name"       : "Sol",
          "color"      : "yellow",
          "x"          : -41,
          "y"          : 27,
          "id"         : 99,
          "station" : {
            "id"       : 2001,
            "x"        : 143,
            "y"        : -27,
            "name"     : "The Death Star",
            "alliance" : {
              "name"     : "The Borg Collective",
              "id"       : 23,
              "image"    : 'my_logo_v001',
            }
          }
          "bodies" : [
            {
              "name"   : "Mercury",
              "id"     : 345,
              "orbit"  : 1,
              "x"      : -40,
              "y"      : 29,
              "type"   : "habitable planet",
              "image"  : "p13",
              "size"   : 58,
              "empire" {
                "id"     : 945,
                "name"   : "Earthlings",
                "alignment"  : "ally",
                "is_isolationist" : 1
              }
            },
            {
              "name"   : "Vesta",
              "id"     : 346,
              "orbit"  : 2,
              "x"      : -39,
              "y"      : 28,
              "type"   : "asteroid",
              "image"  : "p33",
              "size"   : 3,
              "body_has_fissure"  : 1,
            },
            /* ... */
          ]
        },
        {
          /* ... */
        }
        /* ... */
      ]
    }
```

The **station** section is only returned if the star is under the influence of a Space station.

The **empire** section is only returned if the body is occupied by an empire.

## check_star_for_incoming_probe

```json
    {
      "session_id" : "9eea6721-3326-4c1f-817d-a4e82b54818e"
      "star_id"    : "334"
    }
```

If the star has a status of "unprobed", call this method to find out if there is an incoming probe from this empire.

### session_id (required)

A session id.

### star_id (required)

The unique id for a star.

### RESPONSE

```json
{
  "status": {
    /* ... */
  },
  "incoming_probe": "2012 01 31 13:09:05"
}
```

Date of arrival will be present if there is an incoming probe

## get_star

```json
    {
      "session_id" : "9eea6721-3326-4c1f-817d-a4e82b54818e"
      "star_id"    : "334"
    }
```

Retrieves info on a single star.

### session_id (required)

A session id.

### options

You can specify the star by one of the following methods, `star_id`, `star_name`, `star_x`+`star_y`
and you must specify one of these methods only.

### star_id (optional)

The unique id of the star.

### star_name (optional)

The full name of the star.

### x (optional)

The X co-ordinate of the star

### y (optional)

The Y co-ordinate of the star

### RESPONSE

```json
    {
      "star" : {
        "name"          : "Sol",
        "color"         : "yellow",
        "x"             : -41,
        "y"             : 27,
        "zone"          : "0|0",
        "id"            : "99",
        "station" : { // only shows up if this star is under the influence of a space station
          "id" : "id-goes-here",
          "x" : 143,
          "y" : -27,
          "name" : "The Death Star"
        },
        "bodies" : [
           {
                  same data as get_status() on /body
           },
           /* ... */
        ]
      }
      "status" : { /* ... */ }
    }
```

`station` section will only show up if this star is under the influence of a space station

`bodies` will only show up if you or your alliance has a probe, or is within range of an
Oracle.

## find_star

If you know a partial name of a star you can search for it.

```json
    {
      "session_id" : "9eea6721-3326-4c1f-817d-a4e82b54818e"
      "name"       : "lac"
    }
```

### session_id (required)

A session id.

### name (required)

A partial name of a star. Case insensitive. Must be at least 3 characters.

### RESPONSE

```json
{
  "stars": [
    {
      "name": "Sol",
      "color": "yellow",
      "x": -41,
      "y": 27,
      "id": 333
    },
    {
      "name": "Minsol",
      "color": "green",
      "x": -42,
      "y": 27,
      "id": 376
    }
  ],
  "status": {
    /* ... */
  }
}
```

Returns up to 25 names. No body data is returned.

## probe_summary_fissures

```json
    {
      "session_id" : "9eea6721-3326-4c1f-817d-a4e82b54818e"
      "star_id"    : "334"
    }
```

Obtain a summary of all bodies with fissures, known by yours, or your alliances's probes closest to a location.

### options

You can specify the location by one of the following methods, `star_id`, `star_name`, `x`+`y`, `body_id`, `body_name`
and you must specify one of these methods only.

### star_id (optional)

The unique id of the star.

### star_name (optional)

The full name of the star.

### body_id (optional)

The unique id of the star.

### body_name (optional)

The full name of the star.

### x (optional)

The X co-ordinate in the expanse

### y (optional)

The Y co-ordinate in the expanse

### RESPONSE

```json
{
  "fissures": [
    {
      "name": "Mercury",
      "id": 345,
      "orbit": 1,
      "x": -40,
      "y": 29,
      "type": "habitable planet",
      "image": "p13",
      "size": 58,
      "distance": 35
    },
    {
      /* ... */
    }
  ]
}
```

## view_laws (session_id, star_id )

**NOTE:** Pass in a the id of a star and the laws enacted by the controlling station will be returned.

Returns a list of the laws.

```json
{
  "status": {
    /* ... */
  },
  "laws": [
    {
      "id": "id-goes-here",
      "name": "Censure of Jamie Vrbsky",
      "description": "Jamie Vrbsky is bad at playing Lacuna!",
      "date_enacted": "01 31 2010 13:09:05 +0600"
    }
    /* ... */
  ]
}
```

### session_id

A session id.

### star_id

The unique id of the star

Up to 25 fissures are returned sorted by distance, closest first.

Note. If there are fissures on bodies which are in systems for which neither you nor your
alliance have probes, then this data will not be returned.

If there are no fissures on any of the bodies which you have probed, then an empty list is returned;

```

```
