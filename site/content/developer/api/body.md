---
date: 2022-10-31
type: 'page'
---

# Body Methods

These methods are accessible via the `/body` URL.

## get_status

Accepts either fixed arguments, or a hash of named arguments.

    [ session_id, body_id ]

    [{
      "session_id"    : "69627076-34c3-4bb4-8ad4-61c2c6ec2973",
      "body_id"       : "123456"
    }]

### session_id (required)

A session id.

### body_id (required)

The id of the body you wish to retrieve.

### RESPONSE

Returns detailed statistics about a planet.

**NOTE:** You should probably **never** call this method directly, as it is a wasted call
since the data it returns comes back in the status block of every relevant request.
See ["Status" in Intro](/api/Intro#Status) for details.

```json
    {
       "server" : { /* ... */ },
       "empire" : { /* ... */ },
       "body" : {
           "id" : "id-goes-here",
           "x" : -4,
           "y" : 10,
           "star_id" : "id-goes-here",
           "star_name" : "Sol",
           "orbit" : 3,
           "type" : "habitable planet",
           "name" : "Earth",
           "image" : "p13",
           "size" : 67,
           "water" : 900,
           "ore" : {
               "gold" : 3399,
               "bauxite" : 4000,
               /* ... */
           },
           "empire" : { // this section only exists if an empire occupies it
               "id" : "id-goes-here",
               "name" : "Earthlings",
               "alignment" : "ally", // can be 'ally','self', or 'hostile'
               "is_isolationist" : 1
           },
           "station" : { // only shows up if this planet is under the influence of a space station
               "id" : "id-goes-here",
               "x" : 143,
               "y" : -27,
               "name" : "The Death Star"
           },

           --------- if you own the planet the data below will be included ---------

           "needs_surface_refresh" : 1, // indicates that the client needs to call get_buildings() because something has changed
           "building_count" : 7,
           "build_queue_size" : 15, // can build 15 at once
           "build_queue_len" : 10, // have 10 building now
           "plots_available" :60,
           "happiness" : 3939,
           "happiness_hour" : 25,
           "unhappy_date" : "01 13 2014 16:11:21 +0600", // Only given if happiness is below zero
           "neutral_entry" : "01 13 2014 16:11:21 +0600", // Earliest time body can enter neutral area
           "propaganda_boost" : 20,
           "food_stored" : 33329,
           "food_capacity" : 40000,
           "food_hour" : 229,
           "energy_stored" : 39931,
           "energy_capacity" : 43000,
           "energy_hour" : 391,
           "ore_hour" 284,
           "ore_capacity" 35000,
           "ore_stored" 1901,
           "waste_hour" : 933,
           "waste_stored" : 9933,
           "waste_capacity" : 13000,
           "water_stored" : 9929,
           "water_hour" : 295,
           "water_capacity" : 51050,
           "skip_incoming_ships" : 0, // if set, then the following incoming data is missing.
           "num_incoming_enemy" : 10, // total number of incoming foreign ships
           "num_incoming_ally" : 1, // total number of incoming allied ships
           "num_incoming_own : 0, // total number of incoming own ships from other colonies
           "incoming_enemy_ships" : [ // will only be included when enemy ships are coming to your planet (only the first 20 will be shown)
               {
                   "id" : "id-goes-here",
                   "date_arrives" : "01 31 2010 13:09:05 +0600",
                   "is_own" : 1, // is this from one of our own planets
                   "is_ally" : 1                                   # is this from a planet within our alliance
               },
               /* ... */
           ],
           "incoming_ally_ships" : [ // will only be included when allied ships are coming to your planet (only the first 10 will be shown)
               /* ... */
           ],
           "incoming_own_ships" : [ // will only be included when ships from your other colonies are coming to your planet (only the first 10 will be shown)
               /* ... */
           ],

           ----- if the body is a station the follwing information will be included
           "alliance" : {
               "id" : "id-goes-here",
               "name" : "Imperial Empire"
           },
           "influence" : {
               "total" : 0,
               "spent" : 0
           }
       }
    }
```

## get_buildings

    [{
      "session_id"    : "69627076-34c3-4bb4-8ad4-61c2c6ec2973",
      "body_id"       : "123456"
    }]

### session_id (required)

A session id.

### body_id (required)

The id of the body you wish to retrieve.

### RESPONSE

Retrieves a list of the buildings on a planet. The surface of the planet
is made up of an 11x11 tile grid stretching from -5 to 5 in both an x and y
axis. The planetary command centre (or Station Command Centre) is always built at 0,0.

The `get_body` method (among others) will give you `size` and `building_count`.
A planet's size is the number of buildings that can be built on it. The building count
is the number of buildings you have built so far. The maximum size of any planet is
121 (11x11=121), however just because there are spots remaining doesn't mean you can
fill them. Also, sometimes permanent structures such as lakes will occupy a tile
space, and can artificially lower the number of buildings you can place on a planet.

The list of building's retreived by this method should be placed on the 11x11 grid,
and the extra space should be filled in by blank ground tiles.

```json
{
  "buildings": [
    {
      "id": "id-goes-here",
      "name": "Apple Orchard",
      "x": 1,
      "y": -1,
      "url": "/apple",
      "level": 3,
      "image": "apples3",
      "efficiency": 95,
      "pending_build": {
        // only included when building is building/upgrading
        "seconds_remaining": 430,
        "start": "2013 01 31 13:09:05 +0600",
        "end": "2013 01 31 18:09:05 +0600"
      },
      "work": {
        // only included when building is working (Parks, Waste Recycling, etc)
        "seconds_remaining": 49,
        "start": "2013 01 31 13:09:05 +0600",
        "end": "2013 01 31 18:09:05 +0600"
      }
    },
    {
      "id": "id-goes-here",
      "name": "Planetary Command",
      "x": 0,
      "y": 0,
      "url": "/command",
      "level": 1,
      "efficiency": 100,
      "image": "command1"
    }
  ],
  "body": {
    "surface_image": "surface-e"
  },
  "status": {
    /* ... */
  }
}
```

Throws 1002 and 1010.

## repair_list ( session_id, body_id, building_ids)

Repairs buildings in order of ids gived in array.

Returns similar output to get_buildings, but only ones identified in building_ids

### session_id

A session id.

### body_id

The id of the body you wish to retrieve the buildings on.

### building_ids

An array reference to a list of building ids to be repaired.

## rearrange_buildings ( { session_id, body_id, arrangement } )

Rearranges all buildings to the coordinates supplied via the arrangement array of hashes.

```json
    {
       "moved" : [
           {
             "id" : building_id,
             "name" : "Building Name",
             "x" : X coord,
             "y" : Y coord
           }
       ],
       "body" : {
           "surface_image" : "surface-e"
       },
       "status" : { /* ... */ }
    }
```

Throws 1002 and 1010.

### session_id

A session id.

### body_id

The id of the body you wish to arrange buildings on.

### arrangement

A array of hashes.
[
{
"id" : building*id,
"x" : new X coord,
"y" : new Y coord,
},
/* ... \_/
]

All buildings being moved need to be supplied.
PCC or Station Command need to be in position 0,0.

## get_buildable ( session_id, body_id, x, y, tag )

Provides a list of all the building types that are available to be built on a given space on a planet that are within a specific tag.

```json
{
  "max_items_in_build_queue": 6,
  "build_queue": {
    "max": 4,
    "current": 3
  },
  "buildable": {
    "Wheat Farm": {
      "url": "/wheat",
      "build": {
        "can": 1,
        "no_plot_use": 0,
        "cost": {
          "food": 500,
          "water": 500,
          "energy": 500,
          "waste": 500, // is added to your storage, not spent like the other resources
          "ore": 1000,
          "time": 1200
        },
        "extra_level": 7, // only shows up for some plan types, skips level 1 and goes straight to this level
        "tags": ["Now", "Resources", "Food"],
        "reason": ""
      },
      "image": "wheat1",
      "production": {
        "food_hour": 1500,
        "energy_hour": -144,
        "ore_hour": -1310,
        "water_hour": -1100,
        "waste_hour": 133,
        "happiness_hour": 0
      }
    }
    /* ... */
  },
  "status": {
    /* ... */
  }
}
```

If there are multiple plans for a building, this will return the plan with the highest extra_build_level. The build time cost for 1+X plans will show the time for the +X level.

The `reason` section provides a little detail about why a building can or cannot be built. It is formatted the same way an exception would be formatted (an array ref of error code, error message, and error data).

The `tags` section can be used to display the buildable buildings in a way that makes sense to the end user. The tags available are as follows:

- Now

  Can be built right now.

- Soon

  Could be built right now if only there were enough resources in storage.

- Later

  Will eventually become available once you've completed the necessary prerequisites.

- Plan

  This building will be built using a Plan, which means it will cost no resources to build.

- Infrastructure

  Everything that is not a resource building.

  - Intelligence

    This building helps you gain information.

  - Happiness

    This building helps you gain favor with your citizens.

  - Ships

    This building helps you build ships.

  - Colonization

    This building helps you colonize other worlds.

  - Construction

    This building helps in some way building buildings on your planet surface.

  - Trade

    This building allows you to trade good or resources with other players, or assists in trade in some way.

- Resources

  Everything that is not infrastructure.

  - Food

    This building either produces or stores food.

  - Ore

    This building either produces or stores ore.

  - Water

    This building either produces or stores water.

  - Energy

    This building either produces or stores energy.

  - Waste

    This building either consumes or stores waste.

  - Storage

    This building provides storage for one or more of the five resources.

Throws 1002, 1010, 1011, and 1012, and 1013.

### session_id

A session id.

### body_id

The id of the body you wish to retrieve the buildings on.

### x

The x axis of the area on the planet you wish to place the building. Valid values are between -5 and 5 inclusive.

### y

The y axis of the area on the planet you wish to place the building. Valid values are between -5 and 5 inclusive.

### tag

A tag that will limit the list of buildings to return. Required. Cannot be `Now`, `Soon`, or `Later`, but all other tags are fair game.

## get_buildable_locations ( options )

Tells you where you can build buildings. The order of the returned list is not guaranteed.

```json
    {
        "unoccupied": [ [ "2", "-5" ], [ "2", "-4" ], /* ... */ ],
        "status": /* ... */
    }
```

### options

A hash whose keys are:

- session_id

  A session id.

- body_id

  The id of the body you wish to get the free locations of.

- size

  Optional: the size of the building you want to put. If this is 9, then the unoccupied locations will be for the LCOTa (center tile).
  If this is 4, then the unoccupied locations will be for the SSLa (northwest tile). Otherwise, it returns locations for single-tile buildings.

## rename ( session_id, body_id, name )

Renames a body, provided the empire attached to the session owns the body. Returns a 1 on success.

Throws 1000, 1002 and 1010.

### session_id

A session id.

### body_id

The id of the body you wish to rename.

### name

The new name of the body.

## abandon ( session_id, body_id )

Abandons a colony, and destroys everything on the planet. Returns a status block.

### session_id

A session id.

### body_id

The unique id of the body you wish to abandon. You cannot abandon your home planet.

## view_laws (session_id, body_id )

**NOTE:** Pass in a the id of the station, not the id of the parliament building. This is because anyone that wants to should be able to view the laws in this jurisdiction.

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

### body_id

The unique id of the space station.

## set_colony_notes

Sets the per-colony notes for an owned body (colony or station). Returns
a status block.

### session_id

A session id.

### body_id

The unique id of the body whose notes you want to update.

### options

A hash of options. Currently, the only valid key is `notes`, and its
value is the notes to assign.

```

```
