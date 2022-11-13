---
date: 2022-10-31
type: 'page'
---

# Transporter Diagram

The Subspace Transporter is a complex beast, so to help you wrap your brain around it we've created a little flow diagram of how the methods come together.

![Transporter](transporter.png)

# Transporter Methods

The Subspace Transporter is accessible via the URL `/transporter`. It allows you to transport goods across the vastness of space instantly. The catch is that the planet you're transporting to must also have a transporter, and it burns essentia to use it.

The list of methods below represents changes and additions to the methods that all [Buildings](/api/Buildings) share.

## view ( session_id, building_id )

```json
    {
      "building" : { /* ... */ },
      "status" : { /* ... */ },
      "transport" : {
        "max" : 2500,
        "pushable" : [
            "id" : 1234, // body ID
            "name" : "Planet Name",
            "x" : -35,
            "y" : 47,
            "zone" : "0|0",
        ]
      }
    }
```

The alphabetical (on name) pushable list will only include planets with currently-online Transporters.

## add_to_market ( session_id, building_id, offer, ask )

Queues a trade for others to see. In addition to anything offered in your trade, setting up the trade will cost you 1 essentia. Returns:

```json
{
  "trade_id": "id-goes-here",
  "status": {
    /* ... */
  }
}
```

### session_id

A session id.

### building_id

The unique id of the subspace transporter.

### items

An array reference of hash references of items you wish to trade. There are five types of items that can be traded via this mechanism. They are resources, glyphs, plans, prisoners, and ships.

    [
       {
          "type" : "bauxite",
          "quantity" : 10000
       },
       {
          "type" : "prisoner",
          "prisoner_id" : "id-goes-here"
       }
    ]

- resources

  The hash reference for resources looks like:

```json
{
  "type": "bauxite",
  "quantity": 10000
}
```

    - type

        The type of resource you want to trade. See `get_stored_resources` to see what you have available.

    - quantity

        The amount of the resource that you want to trade.

- glyphs

  The hash reference for glyphs looks like:

```json
{
  "type": "glyph",
  "glyph_id": "id-goes-here"
}
```

    - type

        Must be exactly `glyph`.

    - glyph_id

        The unique id of the glyph you want to trade. See the `get_glyphs` method for a list of your glyphs.

- plans

  The hash reference for plans looks like:

```json
{
  "type": "plan",
  "plan_id": "id-goes-here"
}
```

    - type

        Must be exactly `plan`.

    - plan_id

        The unique id of the plan that you want to trade. See the `get_plans` method for a list of your plans.

- prisoners

  The hash reference for prisoners looks like:

```json
{
  "type": "prisoner",
  "prisoner_id": "id-goes-here"
}
```

    - type

        Must be exactly `prisoner`.

    - prisoner_id

        The unique id of the spy that you want to trade. See the `get_prisoners` method for a list of your prisoners.

- ships

  The hash reference for ships looks like:

```json
{
  "type": "ship",
  "ship_id": "id-goes-here"
}
```

    - type

        Must be exactly `ship`.

    - ship_id

        The unique id of the ship that you want to trade. See the `get_prisoners` method for a list of your prisoners.

### ask

An number which represents how much essentia you are asking for in this trade. Must be between 0.1 and 100.

## get_ships ( session_id, building_id )

Returns a list of ships that may be traded. Used with the `add_trade` method.

```json
{
  "ships": [
    {
      "id": "id-goes-here",
      "name": "Enterprise",
      "type": "probe",
      "hold_size": 0,
      "speed": 3900
    }
    /* ... */
  ],
  "cargo_space_used_each": 50000,
  "status": {
    /* ... */
  }
}
```

### session_id

A session id.

### building_id

The unique id of this building.

## get_prisoners ( session_id, building_id )

Returns a list of prisoners that may be traded. Used with the `add_trade` method.

```json
    {
       "prisoners" : [
           {
               "id" : "id-goes-here",
               "name" : "Jack Bauer",
               "level" : "5"
               "sentence_expires" : "01 31 2010 13:09:05 +0600"
           },
           /* ... */
       ],
       "cargo_space_used_each" : 350,
       "status" : { /* ... */ }
    }
```

### session_id

A session id.

### building_id

The unique id of this building.

## get_plans ( session_id, building_id )

Deprecated Method. Please use get_plan_summary instead

## get_plan_summary ( session_id, building_id )

Returns a list of plans that may be traded in summary form.
Used with the `add_trade` method.

```json
{
  "plans": [
    {
      "name": "Intelligence Ministry",
      "level": "7",
      "extra_build_level": "0",
      "quantity": "2"
    }
    /* ... */
  ],
  "cargo_space_used_each": 1000,
  "status": {
    /* ... */
  }
}
```

### session_id

A session id.

### building_id

The unique id of this building

## get_glyphs ( session_id, building_id )

This API call is now deprecated, please use get_glyph_summary instead.

## get_glyph_summary ( session_id, building_id )

Returns a summary of all glyphs that may be traded. Used with the `add_trade` method.

```json
{
  "glyphs": [
    {
      "type": "bauxite",
      "quantity": 2
    }
    /* ... */
  ],
  "cargo_space_used_each": 100,
  "status": {
    /* ... */
  }
}
```

### session_id

A session id.

### building_id

The unique id of this building.

## withdraw_from_market ( session_id, building_id, trade_id )

Remove a trade that you have offered and collect the items up for trade.

```json
{
  "status": {
    /* ... */
  }
}
```

### session_id

A session id.

### building_id

The unique id of this building.

### trade_id

The unique id of the trade.

## accept_from_market ( session_id, building_id, trade_id )

Accept a trade offer from the list of available trades. In addition to paying whatever the asking price is, the subspace transporter uses 1 essentia to complete the transaction. See `view_market`.

Throws 1016.

```json
{
  "status": {
    /* ... */
  }
}
```

### session_id

A session id.

### building_id

The unique id of this building.

### trade_id

The unique id of the trade.

## view_market ( session_id, building_id, [ page_number, filter ] )

Displays a list of trades available at the present time.

```json
{
  "trades": [
    {
      "date_offered": "01 31 2010 13:09:05 +0600",
      "id": "id-goes-here",
      "ask": 25, // essentia
      "offer": ["Level 21 spy named Jack Bauer (prisoner)", "4,000 bauxite", "gold glyph"],
      "empire": {
        "id": "id-goes-here",
        "name": "Earthlings"
      }
    }
    /* ... */
  ],
  "trade_count": 1047,
  "page_number": 1,
  "status": {
    /* ... */
  }
}
```

### session_id

A session id.

### building_id

The unique id of this building.

### page_number

Optional. An integer representing the page of trades (25 per page) to return. Defaults to 1.

### filter

Optional. A string which will narrow the offered trades to those who are offering a specific kind of object, such as ships. Filter options include: food ore water waste energy glyph prisoner ship plan

## view_my_market ( session_id, building_id, [ page_number ] )

Displays a list of trades the current user has posted.

```json
{
  "trades": [
    {
      "date_offered": "01 31 2010 13:09:05 +0600",
      "id": "id-goes-here",
      "ask": 25, // essentia
      "offer": ["Level 21 spy named Jack Bauer (prisoner)", "4,000 bauxite", "gold glyph"]
    }
    /* ... */
  ],
  "trade_count": 17,
  "page_number": 1,
  "status": {
    /* ... */
  }
}
```

### session_id

A session id.

### building_id

The unique id of this building.

### page_number

An integer representing the page of trades (25 per page) to return. Defaults to 1.

## get_stored_resources ( session_id, building_id )

Returns a list of the resources you have stored to make it easier to identify what you want to trade.

```json
{
  "status": {
    /* ... */
  },
  "cargo_space_used_each": 100,
  "resources": {
    "water": 14000,
    "waste": 393,
    "bauxite": 47,
    "cheese": 1193
    /* ... */
  }
}
```

### session_id

A session id.

### building_id

The unique id of this building.

## push_items ( session_id, building_id, target_id, items )

### session_id

A session id.

### building_id

The unique id of this building.

### target_id

The unqiue id of the planet that you control, that you want to send resources to.

**NOTE:** The list of your planets comes back with every empire status message.

### items

An array reference of hash references of items you wish to ship to the target planet. There are five types of items that can be shipped via this mechanism. They are resources, glyphs, plans, prisoners, and ships.

    [
       {
          "type" : "bauxite",
          "quantity" : 10000
       },
       {
          "type" : "prisoner",
          "prisoner_id" : "id-goes-here"
       }
    ]

- resources

  The hash reference for resources looks like:

```json
{
  "type": "bauxite",
  "quantity": 10000
}
```

    - type

        The type of resource you want to push. Available types are: water, energy, waste, essentia, bean, lapis, potato, apple, root, corn, cider, wheat, bread, soup, chip, pie, pancake, milk, meal, algae, syrup, fungus, burger, shake, beetle, rutile, chromite, chalcopyrite, galena, gold, uraninite, bauxite, goethite, halite, gypsum, trona, kerogen, methane, anthracite, sulfur, zircon, monazite, fluorite, beryl, or magnetite.

    - quantity

        The amount of the resource that you want to push.

- glyphs

  The hash reference for glyphs looks like:

```json
{
  "type": "glyph",
  "glyph_id": "id-goes-here"
}
```

    - type

        Must be exactly `glyph`.

    - glyph_id

        The unique id of the glyph you want to push. See the `get_glyphs` method for a list of your glyphs.

- plans

  The hash reference for plans looks like:

```json
{
  "type": "plan",
  "plan_id": "id-goes-here"
}
```

    - type

        Must be exactly `plan`.

    - plan_id

        The unique id of the plan that you want to push. See the `get_plans` method for a list of your plans.

- prisoners

  The hash reference for prisoners looks like:

```json
{
  "type": "prisoner",
  "prisoner_id": "id-goes-here"
}
```

    - type

        Must be exactly `prisoner`.

    - prisoner_id

        The unique id of the spy that you want to push. See the `get_prisoners` method for a list of your prisoners.

- ships

  The hash reference for ships looks like:

```json
{
  "type": "ship",
  "ship_id": "id-goes-here"
}
```

    - type

        Must be exactly `ship`.

    - ship_id

        The unique id of the ship that you want to push. See the `get_prisoners` method for a list of your prisoners.

## trade_one_for_one ( session_id, building_id, have, want, quantity )

Lacuna Expanse Corp will do one for one trades of any resource in exchange for 3 essentia.

```json
{
  "status": {
    /* ... */
  }
}
```

### session_id

A session id.

### building_id

The unique id of this building.

### have

The name of the resource you have. See `get_stored_resources` to see what you have.

### want

The name of any resource you want.

### quantity

The amount of resources that will be traded one for one.

## report_abuse ( session_id, building_id, trade_id )

Report a trade that you think is abusing the trade system.

```json
{
  "status": {
    /* ... */
  }
}
```

### session_id

A session id.

### building_id

The unique id of this building.

### trade_id

The unique id of the trade.

```

```
