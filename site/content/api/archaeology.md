---
date: 2022-10-31
type: 'page'
---

# Archaeology Ministry Methods

Archaeology Ministry is accessible via the URL `/archaeology`.

The list of methods below represents changes and additions to the methods that all [Buildings](/api/Buildings) share.

## view

Accepts either fixed arguments or a hash of named parameters

    ( session_id, building_id )
    ( parameter_hash )

### session_id (required)

A session ID

### building_id (required)

This buildings ID

### RESPONSE

```json
{
  "status": {
    /* ... */
  },
  "building": {
    /* ... */
  }
}
```

If a search is active, the work block will be included. In the work block, there is an additional item not
included in other work blocks: searching. c&lt;searching> will contain the name of the ore being searched.

## search_for_glyph ( session_id, building_id, ore_type )

Searches through ore looking for glyphs left behind by the ancient race. Takes 10,000 of one type of ore to
search.

Accepts either fixed arguments or a hash of named parameters

    ( session_id, building_id, ore_type)
    ( parameter_hash )

### session_id (required)

A session ID

### building_id (required)

This buildings ID

### ore_type (required)

One of the 20 types of ore. Choose from: rutile, chromite, chalcopyrite, galena, gold, uraninite,
bauxite, goethite, halite, gypsum, trona, kerogen, methane, anthracite, sulfur, zircon, monazite,
fluorite, beryl or magnetite

### RESPONSE

Returns **view**.

## subsidize_search ( session_id, building_id )

Will spend 2 essentia to complete the current glyph search immediately.

Accepts either fixed arguments or a hash of named parameters

    ( session_id, building_id )
    ( parameter_hash )

Throws 1011.

### session_id (required)

A session ID

### building_id (required)

This buildings ID

### RESPONSE

Returns **view**

## get_glyph_summary

Returns a summary of all glyphs that may be assembled in this archaeology ministry. Used with the
`assemble_glyphs` method.

Accepts either fixed arguments or a hash of named parameters

    ( session_id, building_id )
    ( parameter_hash )

### session_id (required)

A session ID

### building_id (required)

This buildings ID

### RESPONSE

```json
    {
     "glyphs" : [
       {
         "id" : "id-goes-here",
         "name: : "bauxite",
         "type" : "bauxite",
         "quantity" : 2
       },
       /* ... */
     ],
     "status" : { /* ... */ }
    }
```

## assemble_glyphs

Turns glyphs into rare and ancient items.

Accepts either fixed arguments or a hash of named parameters

    ( session_id, building_id )
    ( parameter_hash )

### session_id (required)

A session ID

### building_id (required)

This buildings ID

### glyphs (required)

An array reference containing an ordered list of up to four glyph types.

### quantity (optional)

Defaults to 1, otherwise specify the number of times to assemble the indicated glyphs up to a maximum of 50.

### RESPONSE

```json
{
  "status": {
    /* ... */
  },
  "item_name": "Volcano"
}
```

## get_ores_available_for_processing

Returns a list of ore names that the user has enough of to process for glyphs.

Accepts either fixed arguments or a hash of named parameters

    ( session_id, building_id )
    ( parameter_hash )

Throws 1011.

### session_id (required)

A session ID

### building_id (required)

This buildings ID

### RESPONSE

```json
{
  "status": {
    /* ... */
  },
  "ore": {
    "bauxite": 39949,
    "rutile": 19393
  }
}
```

## view_excavators

Returns a list of the excavator sites currently controlled by this ministry.

Accepts either fixed arguments or a hash of named parameters

    ( session_id, building_id )
    ( parameter_hash )

Throws 1011.

### session_id (required)

A session ID

### building_id (required)

This buildings ID

### RESPONSE

```json
{
  "status": {
    /* ... */
  },
  "max_excavators": 1,
  "excavators": [
    {
      "id": "id-goes-here",
      "body": {
        "id": "id-goes-here",
        "name": "Kuiper",
        "x": 0,
        "y": -444,
        "image": "a1-5"
        /* ... */
      },
      "artifact": 5,
      "glyph": 30,
      "plan": 7,
      "resource": 53
    }
    /* ... */
  ]
}
```

The `artifact`, `glyph`, `plan` and `resource` numbers give the chances out of 100 that a certain result
will be found by your excavator every hour.

## abandon_excavator ( session_id, building_id, site_id )

Close down an existing excavator site.

Accepts either fixed arguments or a hash of named parameters

    ( session_id, building_id )
    ( parameter_hash )

Throws 1002.

### session_id (required)

A session ID

### building_id (required)

This buildings ID

### site_id (required)

The unique id of the excavator site you wish to abandon.

### RESPONSE

```json
{
  "status": {
    /* ... */
  }
}
```

## mass_abandon_excavator ( session_id, building_id )

Destroy all excavators.

### session_id

A session id.

### building_id

The unique id for the archaeology ministry.

```

```
