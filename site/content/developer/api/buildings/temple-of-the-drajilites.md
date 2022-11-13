---
date: 2022-10-31
type: 'page'
---

# TempleOfTheDrajilites Methods

Temple of the Drajilites is accessible via the URL `/templeofthedrajilites`.

The list of methods below represents changes and additions to the methods that all [Buildings](https://metacpan.org/pod/Buildings) share.

## list_planets (session_id, building_id, \[ star_id \] )

Provides the list of the planets around a given star.

```json
{
  "status": {
    /* ... */
  },
  "planets": [
    {
      "id": "id-goes-here",
      "name": "Earth"
    }
    /* ... */
  ]
}
```

### session_d

A session id.

### building_id

The unique id of the building.

### star_id

Optionally pass in a star id. Defaults to the star that the building is built on. See ["search_stars" in Map](https://metacpan.org/pod/Map#search_stars) to see how you can get a star id by name.

## view_planet ( session_id, building_id, planet_id )

Returns a surface map identical in format to the one returned as an [Inbox](https://metacpan.org/pod/Inbox) attachment.

```json
{
  "status": {
    /* ... */
  },
  "map": {
    "surface_image": "surface-p12",
    "buildings": [
      {
        "x": 1,
        "y": -2,
        "image": "rockyoutcrop1"
      }
      /* ... */
    ]
  }
}
```

### session_id

A session id.

### building_id

The unique id of this building.

### planet_id

The unique id of a planet you want to view. Note that this must be a planet id and not a body id. It won't work for an asteroid for example. Also, the planet must be in range. You get 10 star map units per level of the Temple.

```

```
