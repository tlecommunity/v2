---
date: 2022-10-31
type: 'page'
---

# Trade Ministry Methods

The Trade Ministry is accessible via the URL `/trade`. It allows you to send cargo ships to other
players with trade goods. Due to the vast distance of space, your trade ministry can only announce
trades within a certain distance, based on your TM level.

The list of methods below represents changes and additions to the methods that all [Buildings](/api/Buildings) share.

## General arguments

Some arguments are used in similar ways in several calls. They are described here in more detail.

### target

Typically the Target for a fleet.

TODO

## accept_from_market

Accept a trade offer from the list of available trades. See `view_market`.

Accepts either fixed arguments or a hash of named parameters

    ( session_id, building_id, trade_id)
    ( parameter_hash )

### session_id (required)

A session ID.

### building_id (required)

This building's ID

### trade_id (required)

The unique ID of the trade being accepted.

### RESPONSE

Returns the same as `view`

## add_fleet_to_supply_duty

Take a fleet from your space port and put them on duty supporting your supply chains.

Accepts either fixed arguments or a hash of named parameters

    ( session_id, building_id, fleet_id )
    ( parameter_hash )

Throws 1009.

### session_id (required)

A Session ID.

### building_id (required)

The unique ID of the Trade Ministry.

### fleet_id (required)

The unique ID of the ship you want to add to the fleet.

### quantity (optional)

Only available in the named argument call method. The number of ships to put on duty.
Defaults to all ships in the fleet.

### RESPONSE

Returns the same as `view`

## add_fleet_to_waste_duty

Take a fleet from your space port and put them on duty supporting your waste chains.

Accepts either fixed arguments or a hash of named parameters

    ( session_id, building_id, fleet_id )
    ( parameter_hash )

Throws 1009.

### session_id (required)

A Session ID.

### building_id (required)

The unique ID of the Trade Ministry.

### fleet_id (required)

The unique ID of the ship you want to add to the fleet.

### quantity (optional)

Only available in the named argument call method. The number of ships to put on duty.
Defaults to all ships in a fleet.

### RESPONSE

Returns the same as `view`

## add_to_market

Accepts either fixed arguments or a hash of named parameters

    ( session_id, building_id, offer, ask, fleet_id )
    ( parameter_hash )

### session_id (required)

A Session ID.

### building_id (required)

The unique ID of the Trade Ministry.

### offer (required)

An array reference of hash references of items you wish to trade.
There are five types of items you can trade via this mechanism.
They are `resources` `glyphs` `plans` `prisoners` and `fleets`

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

  The hash reference for glyphs looks like this:

```json
        {
          "type" : "glyph",
          "name : "bauxite",
          "quantity" : 3
        }
```

    - type

        Must be exactly `glyph`.

    - name

        The type of glyph you want to trade (must be an ore type name).

    - quantity

        The number of glyphs of type `name` that you want to trade

- plans

  The hash reference for plans looks like this:

```json
{
  "type": "plan",
  "plan_type": "Permanent_AlgaePond",
  "level": 1,
  "extra_build_level": 5,
  "quantity": 4
}
```

    - type

        Must be exactly `plan`.

    - plan_type

        Same as returned by get_plan_summary.

    - level

        Level of the plan being added.

    - extra_build_level

        Extra level of plan to build to. Note this will be 0 except possibly where the level is 1.

    - quantity

        Number of plans to add.

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

- fleets

  The hash reference for ships looks like:

```json
{
  "type": "fleet",
  "fleet_id": "id-goes-here",
  "quantity": 3
}
```

    - type

        Must be exactly `fleet`.

    - fleet_id

        The unique id of the fleet that you want to trade. See the `get_tradeable_fleets` method for a list of your fleets.

    - quantity

        The number of ships in the fleet to offer in trade.

### ask

A number representing the amount of essentia you are asking for this trade. Must be a number between 0.1 and 99.9.

### fleet_id (optional)

The ID of the fleet you want to use to transport this trade. See `get_trade_fleets` for details.

If you don't specify a fleet_id then it will take the first available fleet for the trade.

The quantity of ships to send will be based on the number of ships in the fleet and the cargo capacity
of each ship in the fleet. You do not need to specify this, it will be calculated for you.

### RESPONSE

Returns the ID of the trade just created.

```json
{
  "trade_id": "id-goes-here",
  "status": {
    /* ... */
  }
}
```

## create_supply_chain

Adds a new supply chain. Note. This creates the supply chain but does not allocate ships to service
the supply chains.

Accepts either fixed arguments or a hash of named parameters

    ( session_id, building_id, target resource_type resource_hour )
    ( parameter_hash )

### session_id (required)

A Session ID.

### building_id (required)

The unique ID of the Trade Ministry.

### target_id (required)

The ID of the target planet (or space station). Note this is required for fixed arguments
method, but may be replaced by `target` with named arguments.

### target (optional)

You can specify a target, for example by name or x,y co-ordinates. (see above). Only inhabited bodies
or Space Stations can be specified. Do not use together with c&lt;target_id>.

### resource_type (required)

Is the resource you want to push, e.g. 'waste','water','gold','energy','apple', etc.

### resource_hour (required)

The amount of the resource you want to transfer each hour.

### RESPONSE

Returns the same as the call to **view_supply_chains**

## get_tradeable_fleets

Accepts either fixed arguments or a hash of named parameters

    ( session_id, building_id )
    ( parameter_hash )

### session_id (required)

A Session ID.

### building_id (required)

The unique ID of the Trade Ministry.

### RESPONSE

Returns a list of fleets that may be traded. Used with the `add_to_market` method.

```json
{
  "fleets": [
    {
      "id": "id-goes-here",
      "name": "Fast Probes",
      "type": "probe",
      "hold_size": 0,
      "speed": 7900,
      "quantity": 32
    }
    /* ... */
  ],
  "cargo_space_used_each": 10000,
  "status": {
    /* ... */
  }
}
```

**cargo_space_used_each** is the amount of cargo space each ship takes.

## get_prisoners

Accepts either fixed arguments or a hash of named parameters

    ( session_id, building_id )
    ( parameter_hash )

### session_id (required)

A Session ID.

### building_id (required)

The unique ID of the Trade Ministry.

### RESPONSE

Returns a list of prisoners that may be traded. Used with the `add_trade` method.

```json
{
  "prisoners": [
    {
      "id": "id-goes-here",
      "name": "Jack Bauer",
      "level": "5",
      "sentence_expires": "01 31 2010 13:09:05 +0600"
    }
    /* ... */
  ],
  "cargo_space_used_each": 350,
  "status": {
    /* ... */
  }
}
```

**cargo_space_used_each** is the amount of cargo space each prisoner takes.

## get_plans

Accepts either fixed arguments or a hash of named parameters

    ( session_id, building_id )
    ( parameter_hash )

### session_id (required)

A Session ID.

### building_id (required)

The unique ID of the Trade Ministry.

### RESPONSE

Returns a list of plans that may be traded in summary form.

```json
{
  "plans": [
    {
      "name": "Intelligence Ministry",
      "plan_type": "Intelligence",
      "level": "7",
      "extra_build_level": "0",
      "quantity": "2"
    }
    /* ... */
  ],
  "cargo_space_used_each": 10000,
  "status": {
    /* ... */
  }
}
```

**cargo_space_used_each** is the amount of cargo space each prisoner takes.

## get_glyphs

Accepts either fixed arguments or a hash of named parameters

    ( session_id, building_id )
    ( parameter_hash )

### session_id (required)

A Session ID.

### building_id (required)

The unique ID of the Trade Ministry.

### RESPONSE

Returns a summary of all glyphs that may be traded.

```json
    {
      "glyphs" : [
        {
          "id"         : "id-goes-here",
          "name:       : "bauxite",
          "type"       : "bauxite",
          "quantity"   : 2
        },
        /* ... */
      ],
      "cargo_space_used_each" : 100,
      "status" : { /* ... */ }
    }
```

## withdraw_from_market ( session_id, building_id, trade_id )

Accepts either fixed arguments or a hash of named parameters

    ( session_id, building_id, trade_id )
    ( parameter_hash )

### session_id (required)

A Session ID.

### building_id (required)

The unique ID of the Trade Ministry.

### trade_id (required)

The unique ID of the trade to be withdrawn.

### RESPONSE

Remove a trade that you have offered and collect the items up for trade.

```json
{
  "status": {
    /* ... */
  }
}
```

## accept_from_market

Accept a trade offer from the list of available trades. See `view_market`.

Accepts either fixed arguments or a hash of named parameters

    ( session_id, building_id, trade_id )
    ( parameter_hash )

### session_id (required)

A Session ID.

### building_id (required)

The unique ID of the Trade Ministry.

### trade_id (required)

The unique ID of the trade to be accepted.

### RESPONSE

Throws 1016.

```json
{
  "status": {
    /* ... */
  }
}
```

## view_market

Accepts either fixed arguments or a hash of named parameters

    ( session_id, building_id, trade_id )
    ( parameter_hash )

### session_id (required)

A Session ID.

### building_id (required)

The unique ID of the Trade Ministry.

### page_number (optional)

Optional. An integer representing the page of trades (25 per page) to return. Defaults to 1.

### filter (optional)

Optional. A string which will narrow the offered trades to those who are offering a specific kind of object.
Filter options include: food ore water waste energy glyph prisoner ships plan

### RESPONSE

Displays a list of trades available at the present time.

```json
    {
      "trades" : [
        {
          "date_offered" : "01 31 2010 13:09:05 +0600",
          "id" : "id-goes-here",
          "ask" : 25, // essentia
          "offer" : [
            "Level 21 spy named Jack Bauer (prisoner)",
            "4,000 bauxite",
            "32 gold glyph",
            "2 Algae Pond (1) plan",
            "1 Smuggler Ship (speed: 5984, stealth: 13,850, hold_size: 207,371, berth: 10, combat: 2)"
          ],
          "body" : {
            "id" : "id-goes-here"
          },
          "empire" : {               "id" : "id-goes-here",
            "name" : "Earthlings"
          },
          "delivery: : {
            "duration" : 3600, // travel time in seconds
          }
        },
        /* ... */
      ],
      "trade_count" : 1047,
      "page_number" : 1,
      "status" : { /* ... */ }
    }
```

### filter

Optional. A string which will narrow the offered trades to those who are offering a specific kind of object.
Filter options include: food ore water waste energy glyph prisoner ship plan

## view_my_market

Accepts either fixed arguments or a hash of named parameters

    ( session_id, building_id, trade_id )
    ( parameter_hash )

### session_id (required)

A Session ID.

### building_id (required)

The unique ID of the Trade Ministry.

### page_number (optional)

Optional. An integer representing the page of trades (25 per page) to return. Defaults to 1.

### RESPONSE

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

## get_trade_fleets

Accepts either fixed arguments or a hash of named parameters

    ( session_id, building_id, target_body_id )
    ( parameter_hash )

### session_id (required)

A Session ID.

### building_id (required)

The unique ID of the Trade Ministry.

### target_body_id (optional)

The unique id of the body you'll be shipping to. Optional. If included it will calculate the estimated travel time of the fleets to this body.

### RESPONSE

Returns a list of the fleets that could be used to transport a trade.

```json
{
  "status": {
    /* ... */
  },
  "fleets": [
    {
      "id": "id-goes-here",
      "type": "cargo_ship",
      "name": "SS Minnow",
      "quantity": 130,
      "estimated_travel_time": 3600
      /* ... */
    }
    /* ... */
  ]
}
```

## get_waste_fleets

Accepts either fixed arguments or a hash of named parameters

    ( session_id, building_id )
    ( parameter_hash )

### session_id (required)

A Session ID.

### building_id (required)

The unique ID of the Trade Ministry.

### RESPONSE

Returns a list of the fleets that are either working to transport waste or available.

```json
{
  "status": {
    /* ... */
  },
  "fleet": [
    {
      "id": "id-goes-here",
      "type": "scow",
      "task": "Docked",
      "quantity": 32,
      "name": "Dumper Truck 1",
      "speed": 600,
      "hold_size": 1234800
    }
    /* ... */
  ]
}
```

## get_supply_fleets

Accepts either fixed arguments or a hash of named parameters

    ( session_id, building_id )
    ( parameter_hash )

### session_id (required)

A Session ID.

### building_id (required)

The unique ID of the Trade Ministry.

### RESPONSE

Returns a list of the fleets that are either working to transport supplies or available.

```json
{
  "status": {
    /* ... */
  },
  "ships": [
    {
      "id": "id-goes-here",
      "type": "hulk",
      "task": "Resource Chain",
      "quantity": 32,
      "name": "Big Momma 1",
      "speed": 1000,
      "hold_size": 4000000
    }
    /* ... */
  ]
}
```

## view_supply_chains

Accepts either fixed arguments or a hash of named parameters

    ( session_id, building_id )
    ( parameter_hash )

### session_id (required)

A Session ID.

### building_id (required)

The unique ID of the Trade Ministry.

### RESPONSE

Returns a list of the supply chains currently controlled by this Trade Ministry

```json
{
  "status": {
    /* ... */
  },
  "supply_chains": [
    {
      "id": "id-goes-here",
      "body": {
        "id": "id-goes-here",
        "name": "Mars",
        "x": 0,
        "y": -123
        /* ... */
      },
      "building_id": 1234567,
      "resource_hour": 10000000,
      "resource_type": "water",
      "percent_transferred": 95,
      "stalled": 0
    }
  ],
  "max_supply_chains": 30
}
```

Each supply-chain can transfer any amount of any one resource (food type, ore type
energy, waste or water). **max_supply_chains** shows you how many Supply Chains
your Trade Ministry can handle.

The **building_id** is the identifier for the Trade Ministry that is the source of the
supply chain.

The **resource_type** is the name of the resource being transferred (e.g. 'Gold');

The **resource_hour** is the amount of that resource being transferred each hour.

The **percent_transferred** is the percentage of **resource_hour** that is actually transferred.
This is based on the number of ships you have servicing the chain. If you have no ships then
the **percent_transferred** will be zero. If it is below 100 then you need to add ships so that
it is at or above 100. Above 100 and you have more ship capacity than you need, but you will
still only transfer the specified **resource_hour**, it just means some ships will be idle or not
fully filled.

**stalled** is true if there are no more of the chain's resource available in storage to push.

## view_waste_chains

Accepts either fixed arguments or a hash of named parameters

    ( session_id, building_id )
    ( parameter_hash )

### session_id (required)

A Session ID.

### building_id (required)

The unique ID of the Trade Ministry.

### RESPONSE

Returns a list of the waste chains currently controlled by this Trade Ministry

```json
{
  "status": {
    /* ... */
  },
  "waste_chain": [
    {
      "id": "id-goes-here",
      "star": {
        "id": "id-goes-here",
        "name": "Sol",
        "x": 0,
        "y": -123
        /* ... */
      },
      "waste_hour": 10000000,
      "percent_transferred": 95
    }
  ]
}
```

Note, there is no need to create a waste chain, all planets have a waste chain by default.

There should only be one waste-chain in action, to your local star. There is no point in
setting up a waste-chain to any other star.

The **waste_hour** is the amount of waste you wish to transfer per hour.

The **percent_transferred** is the percentage of **waste_hour** that is actually transferred.
This is based on the number of ships you have servicing the waste. If you have no ships then
the **percent_transferred** will be zero. If it is below 100 then you need to add ships so that
it is at or above 100. Above 100 and you have more ship capacity than you need, but you will
still only transfer the specified **waste_hour**, it just means some ships will be idle or not
fully filled.

## delete_supply_chain

Accepts either fixed arguments or a hash of named parameters

    ( session_id, building_id )
    ( parameter_hash )

### session_id (required)

A Session ID.

### building_id (required)

The unique ID of the Trade Ministry.

### supply_chain_id (required)

The unique iD of the supply chain you wish to delete.

### RESPONSE

Returns the same as the call to **view_supply_chains**

## update_supply_chain ( session_id, building_id, supply_chain_id, resource_type, resource_hour)

Accepts either fixed arguments or a hash of named parameters

    ( session_id, building_id, supply_chain_id, resource_type, resource_hour )
    ( parameter_hash )

### session_id (required)

A Session ID.

### building_id (required)

The unique ID of the Trade Ministry.

### supply_chain_id (required)

The unique iD of the supply chain you wish to update.

### resource_type (optional)

Change the chain to this resource type. If not specified, the resource type remains unchanged.

### resource_hour (optional)

Change the chain to this amount per hour. If not specified, the resource per hour remains unchanged.

### RESPONSE

Change the **resource_type** and **resource_hour** for the supply Chain specified by **supply_chain_id**

Returns the same as the call to **view_supply_chains**

Note, the **percent_transferred** may drop below 100% as a result of changing the amount of
**resource_hour** if you don't have enough ships to transfer the amount of resources in all
supply chains.

You may set the resource_hour to zero if you want to suspend the supply chain to the target planet.

If you want to remove the supply chain totally then call **delete_supply_chain**

## update_waste_chain

Accepts either fixed arguments or a hash of named parameters

    ( session_id, building_id, waste_chain_id, waste_hour )
    ( parameter_hash )

### session_id (required)

A Session ID.

### building_id (required)

The unique ID of the Trade Ministry.

### waste_chain_id (required)

The unique iD of the supply chain you wish to update.

### waste_hour (optional)

Change the waste chain to this amount per hour. If not specified, the waste/hr remains unchanged.

### RESPONSE

Change the **waste_hour** for the Waste Chain specified by **waste_chain_id**

Returns the same as the call to **view_waste_chains**

Note, the **percent_transferred** may drop below 100% as a result of changing the amount of
**waste_hour** if you don't have enough ships to transfer the full amount of waste.

Note, there is no **create_waste_chain** because all planets have a waste chain by default.

You may set the **waste_hour** to zero if you want to stop transferring waste.

## remove_supply_fleet

Remove a number of ships from a fleet which is servicing your supply chains and tell
them to return to port.

Accepts either fixed arguments or a hash of named parameters

    ( session_id, building_id, building_id, fleet_id, quantity )
    ( parameter_hash )

### session_id (required)

A Session ID.

### building_id (required)

The unique ID of the Trade Ministry.

### fleet_id (required)

The unique ID of the fleet.

### quantity (optional)

The number of ships to remove from the fleet. If not specified, the whole fleet is removed.

### RESPONSE

Returns the same as the call to **view_supply_chains**

Throws 1009.

## remove_waste_fleet

Remove a number of ships from a fleet which is servicing your waste management and tell
them to return to port.

Accepts either fixed arguments or a hash of named parameters

    ( session_id, building_id, building_id, fleet_id, quantity )
    ( parameter_hash )

### session_id (required)

A Session ID.

### building_id (required)

The unique ID of the Trade Ministry.

### fleet_id (required)

The unique ID of the fleet.

### quantity (optional)

The number of ships to remove from the fleet. If not specified, the whole fleet is removed.

### RESPONSE

Returns the same as the call to **view_waste_chains**

Throws 1009.

## get_stored_resources

Accepts either fixed arguments or a hash of named parameters

    ( session_id, building_id, building_id )
    ( parameter_hash )

### session_id (required)

A Session ID.

### building_id (required)

The unique ID of the Trade Ministry.

### RESPONSE

Returns a list of the resources you have stored to make it easier to identify what you want to trade.

```json
{
  "status": {
    /* ... */
  },
  "cargo_space_used_each": 1,
  "resources": {
    "water": 14000,
    "waste": 393,
    "bauxite": 47,
    "cheese": 1193
    /* ... */
  }
}
```

## push_items

This now only takes a hash of named arguments due to the complexity of the call.

```json
{
  "session_id": "session-id-here",
  "building_id": "building-id-here",
  "target": { "body_name": "Earch" },
  "items": [{ "type": "bauxite" }, { "type": "prisoner", "prisoner_id": 434 }],
  "fleet": {
    "id": 334,
    "quantity": 2,
    "stay": 2
  }
}
```

### session_id (required)

A Session ID.

### building_id (required)

The unique ID of the Trade Ministry.

### target (required)

The target ID, x|y, name as described in SpacePort - target.

Only inhabited bodies or Space Stations can be specified.

### items

An array reference of hash references of items you wish to ship to the target planet. There are five types of items that can be shipped via this mechanism. They are resources, glyphs, plans, prisoners, and ships.

    [
      {
        "type"         : "bauxite",
        "quantity"     : 10000
      },
      {
        "type"         : "prisoner",
        "prisoner_id"  : "id-goes-here"
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

        The type of resource you want to push. Available types are: water, energy, waste, essentia, bean, lapis, potato, apple,
        root, corn, cider, wheat, bread, soup, chip, pie, pancake, milk, meal, algae, syrup, fungus, burger, shake, beetle,
        rutile, chromite, chalcopyrite, galena, gold, uraninite, bauxite, goethite, halite, gypsum, trona, kerogen, methane,
        anthracite, sulfur, zircon, monazite, fluorite, beryl, or magnetite.

    - quantity

        The amount of the resource that you want to push.

- glyphs

  The hash reference for glyphs looks like:

```json
        {
           "type"      : "glyph",
           "name       : "bauxite",
           "quantity"  : 3
        }
```

    - type

        Must be exactly `glyph`.

    - name

        The type of glyph you want to trade (must be an ore type name).

    - quantity

        The number of glyphs of type `name` that you want to push.

        See the `get_glyph_summary` method for a list of your glyphs.

- plans

  The hash reference for plans looks like this:

```json
{
  "type": "plan",
  "plan_type": "Permanent_AlgaePond",
  "level": 1,
  "extra_build_level": 5,
  "quantity": 4
}
```

    - type

        Must be exactly `plan`.

    - plan_type

        Same as returned by get_plan_summary.

    - level

        Level of the plan being pushed.

    - extra_build_level

        Level of plus to plan.  Note this will be 0 except possibly when the base level is 1.

    - quantity

        The number of plans of that you want to push.

        See the `get_plan_summary` method for a list of your plans.

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

- fleets

  The hash reference for fleets looks like:

```json
{
  "type": "fleet",
  "fleet_id": "id-goes-here",
  "quantity": 23
}
```

    - type

        Must be exactly `fleet`.

    - fleet_id

        The unique id of the fleet that you want to push. See the `get_tradeable_fleets` method for a list of your fleets.

### fleet

A hash reference to define what fleet should be used to transport the trade.

- id (required)

  The specific id of a fleet you want to use for this push. See `get_trade_fleets` for details.

- quantity (optional)

  The number of ships in the fleet to transport the cargo. If not specified the minimum number of ships will be split from the fleet and sent.

- stay (optional)

  The number of ships in the fleet to remain at the target planet instead of making a round trip.
  This does however require there to be available spaceport docks on the target planet.

  Note. In a change from previous releases, the fleet, on it's outward journey, remains under control of the **sending** colony. From this release
  the fleet remains under the control of the sending colony until it arrives.

### RESPONSE

```json
{
  "status": {
    /* ... */
  },
  "fleet": {
    "id": 34234,
    "name": "SS Minnow",
    "type": "cargo_ship",
    "quantity": 2,
    "stay": 0,
    "date_arrives": "01 31 2010 13:09:05 +0600"
    /* ... */
  }
}
```

## report_abuse

Accepts either fixed arguments or a hash of named parameters

    ( session_id, building_id, waste_chain_id, waste_hour )
    ( parameter_hash )

### session_id (required)

A Session ID.

### building_id (required)

The unique ID of the Trade Ministry.

### trade_id (required)

The ID of the trade you wish to report.

### RESPONSE

Report a trade that you think is abusing the trade system.

```json
{
  "status": {
    /* ... */
  }
}
```

# POD ERRORS

Hey! **The above document had some coding errors, which are explained below:**

- Around line 303:

  &#x3d;back without =over

```

```
