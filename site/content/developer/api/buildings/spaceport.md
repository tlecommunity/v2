---
date: 2022-10-31
type: 'page'
---

# Space Port Methods

Space Port is accessible via the URL `/spaceport`.

The Space Port is where all the ships you build will be docked once they have been built from the [Shipyard](/api/Shipyard).
You can dock twice as many ships as the level of the Space Port.

The list of methods below represents changes and additions to the methods that all [Buildings](/api/Buildings) share.

Note that a fleet comprises a number of ships, all of the same type, speed, stealth, name and task. A fleet
that is involved in a battle may be damaged in which case some of the ships will be damaged or destroyed.
This is shown by the **quantity** having a none integer value, e.g. **10.1**

## target

Some of the Space Port methods allow ships to be sent to targets. This parameter is described here.

A hash reference that can contain one of the following items to identify a star or body.

```json
{ "body_name": "Earth" }
```

    { "body_id" : "id-goes-here" }

```

    { "star_name" : "Sol" }
```

    { "star_id" : "id-goes-here" }

```

    { "x" : 4, "y" : -3 }
```

```json
{ "bookmark": "Enemy Target 1" }
```

#### body_name

A string with the body's name. Case insensitive, but will throw an exception for misspelling.

#### body_id

The unique id of the body.

#### star_name

A string with the star's name. Case insensitive, but will throw an exception for misspelling.

#### star_id

The unique id of the star.

#### x | y

A set of x,y coordinates to locate the star or body.

#### bookmark

A string containing a bookmark which locates a star or body.

## paging

Some of the Space Port methods allow the results to be paged. This parameter is described here.

If no paging options are selected, then it defaults to 25 items_per_page and page_number 1

### paging

Optional. A hash reference that contains the paging criteria. Valid paging option keys include page_number, items_per page and no_paging.

#### page_number

Optional. An integer representing the page of ships to return. Defaults to 1.

#### items_per_page

Optional. An integer representing the number of items per page to return. Defaults to 25.

#### no_paging

Optional. If set to 1, all other paging options are ignored and all results will be retured.

```json
{ "no_paging": 1 }
```

```json
{ "page_number": 2, "items_per_page": 30 }
```

## filter

Some of the SpacePort methods allow the fleets to be filtered. This parameter is described here.

If no filter option is selected, then it defaults to returning all entries.

### filter

Optional: A hash reference that contains the filter criteria.
Valid filter option keys include task, type and tag.

### task

Optional. An array reference or string with the task(s) to filter on. Valid tasks include Docked, Building,
Mining, Travelling, Defend, Orbiting, 'Waiting On Trade', 'Supply Chain' and 'Waste Chain'.

### type

Optional. An array reference or string with the type(s) to filter on. Valid types are the existing ship types.

### tag

Optional. An array reference or string with the tag(s) to filter on. Valid tags include Trade, Colonization,
Intelligence, Exploration, War, Mining, SupplyChain WasteChain.

Note: Tags will be converted to types prior to filtering and any types that were passed will be replaced.

```json
{ "task": "Defend" }
```

```json
{ "tag": "Mining" }
```

```json
{ "task": "Docked", "type": "freighter" }
```

```json
{ "tag": ["Colonization", "Exploration"], "task": "Travelling" }
```

## sort

Some of the SpacePort methods allow the list of fleets to be sorted.

Optional. A string with the column to sort on. Defaults to 'type'.

Valid columns to sort on are combat, name, speed, stealth, task and type.

A second sort colomn, 'name', is added to your chosen sort column (unless it happened to also be 'name')

\-----------------------------------------------------------------------------------------

## view

This method is extended to include a list of docked ships.

Accepts either positional inputs or named arguments.

    ( <session_id>, <building_id> )

    ({
      "session_id"    : "e6ebd970-7036-4aa2-a80f-1ae67109fb4e",
      "building_id"   : 23454,
    })

### session_id (required)

A session ID

### building_id (required)

This buildings ID

### RESPONSE

```json
{
  "building": {
    /* ... */
  },
  "status": {
    /* ... */
  },
  "max_ships": 8,
  "docks_available": 4,
  "docked_ships": {
    "probe": 3,
    "cargo_ship": 0,
    "spy_pod": 1,
    "colony_ship": 0,
    "terraforming_platform_ship": 0,
    "gas_giant_settlement_platform_ship": 0,
    "mining_platform_ship": 0,
    "smuggler_ship": 1,
    "space_station": 0
  }
}
```

## view_all_fleets

View all of your fleets, on this planet, whatever they are doing.

Accepts either positional inputs or named arguments.

    ( <session_id>, <building_id> )

    ({
      "session_id"    : "e6ebd970-7036-4aa2-a80f-1ae67109fb4e",
      "building_id"   : 23454,
      "paging"        : {
          "page_number"       : 1,
          "items_per_page"    : 20
      },
      "filter"    : {
          task :  "Docked",
          tag  :  "War"
      },
      "sort"      : "combat"
    })

Note that the optional, pagin, filter and sort options are only
available with the named arguments calling convention.

### session_id (required)

A session ID

### building_id (required)

This buildings ID

### paging (optional)

See above.

### filter (optional)

See above

### sort (optional)

See above

### RESPONSE

```json
    {
      'number_of_fleets' => '25',
      'status'           => { /* ... */ },
      'fleets'           => [
        {
          'quantity' => '10.1',
          'id'       => '1414',
          'task'     => 'Docked',
          'details'  => {
            'can_recall'     => 0,
            'name'           => 'Detonator',
            'date_available' => '01 01 2000 00:00:00 +0000',
            'stealth'        => '0',
            'combat'         => '5624',
            'max_occupants'  => 0,
            'mark'           => 'f1795e49c0',
            'can_scuttle'    => 1,
            'speed'          => '2920',
            'hold_size'      => '0',
            'berth_level'    => '1',
            'payload'        => [],
            'type'           => 'detonator',
            'type_human'     => 'Detonator',
            'date_started'   => '01 01 2000 00:00:00 +0000'
          }
        },
        {
          'to' => {
            'name'   => 'Mars',
            'id'     => '224',
            'type'   => 'body',
            'owner'  => 'Foreign',
            'x'      => '388',
            'y'      => '-22',
            'empire' => {
              'id'     => '332',
              'name'   => 'Martian'
            }
          },
          'from' => {
            'name'   => 'Earth',
            'id'     => '221',
            'type'   => 'body',
            'owner'  => 'Own',
            'x'      => '344',
            'y'      => '12',
            'empire' => {
              'id'     => '323',
              'name'   => 'Man'
            }
          },
          'quantity'     => '1.0',
          'id'           => '1548',
          'task'         => 'Travelling',
          'date_arrives' => '25 12 2012 08:00:00 +0000',
          'details'      => {
            'can_recall'     => 1,
            'name'           => 'Fighter',
            'date_available' => '25 12 2012 08:00:00 +0000',
            'stealth'        => '0',
            'combat'         => '15760',
            'max_occupants'  => 0,
            'mark'           => '7d8870d975',
            'can_scuttle'    => 1,
            'speed'          => '7640',
            'hold_size'      => '0',
            'berth_level'    => '1',
            'payload'        => [],
            'type'           => 'fighter',
            'type_human'     => 'Fighter',
            'date_started'   => '17 08 2012 15:58:48 +0000',
            'current_location' => {
              'x'  => '332.5',
              'y'  => '20.2',
            }
          }
        }
      ]
    }
```

The **number_of_fleets** is the total number of fleets. (Not all fleets will be
seen in the **incoming** section if paging is in effect).

**owner** in the **from** section should all be 'Own' since this API call only
shows ships from our own planet.

The **from** and **to** sections will only be displayed for ships that are
travelling, orbiting or defending.

Note that you will always see full info for your own, or allied incoming fleets.

The **current_location** section will only occur for ships which have task
'Travelling', 'Defend' or 'Orbiting'; For a ship that is travelling, it shows
the estimated location of the ship based on it's speed and direction.

## view_incoming_fleets

Shows incoming fleets for a specific target.

Accepts either fixed arguments or a hash of named parameters

    ( session_id, target, filter, sort )
    ( parameter_hash )

### session_id (required)

A session ID

### target (required)

The target of the incoming fleets. See above for this option.

### filter, sort (optional)

See above for these options.

### RESPONSE

```json
    {
      "number_of_incoming_fleets" : 3,
      "number_of_incoming_ships" : 25,
      "incoming" : [
        {
          "id" : "id-goes-here",
          "quantity" : 1.0,
          "task" : "Travelling",
          "details" {
            "name" : "P13",
            "mark" : "A3123AB8ED",
            "type_human" : "Probe",
            "type" : "probe",
            "speed" : "1200",
            "stealth" : "0",
            "combat" : "0",
            "hold_size" : "0",
            "berth_level" : "1",
            "date_started" : "01 31 2010 13:09:05 +0600",
            "date_available" : "02 01 2010 10:08:33 +0600",
            "max_occupants" : "0",
            "payload" : "{}",
            "can_scuttle" : "0",
            "can_recall" : "0",
          },
          "date_arrives" : "02 01 2010 10:08:33 +0600",
          "from" : {
            "id" : "id-goes-here",
            "type" : "body",
            "name" : "Earth",
            "owner" : "Allied",
            "empire" : {
              "id" : "id-goes-here",
              "name" : "Earthlings"
            }
          },
          "to" : {
            "id" : "id-goes-here",
            "type" : "star",
            "name" : "Sol",
          }
        },
        /* ... */
      ],
      "status" : { /* ... */ }
    }
```

The **number_of_incoming** is the total number of incoming fleets. (Not all fleets will be
seen in the **incoming** section if paging is in effect).

**owner** in the **from** section specifies either 'Own', 'Allied" or "Foreign" depending upon
who the fleet is from.

You will only see 'foreign' ships if the target is either your own or an allies planet, and then
the fleet information will be filtered depending upon the highest level of Spaceport on the target.

To see the `from` block :-

    SpacePort Level * 450 >= Fleet Stealth

To see the `details` block :-

    SpacePort level * 350 >= Fleet Stealth

Note that you will always see full info for your own, or allied incoming fleets.

## view_available_fleets

Get a list of fleets that are available to send to a specified target.

Only accepts named arguments.

    ({
      "session_id"    : "e6ebd970-7036-4aa2-a80f-1ae67109fb4e",
      "body_id"       : 23235,
      "target"        : {
          "body_name" : "Earth"
      },
      "filter"    : {
          "tag"   :  "War"
      },
      "sort"      : "combat"
    })

### session_id (required)

A session ID

### body_id (required)

The ID of the body you are sending fleets from

### target (required)

The target to send a fleet to. See above for this option.

### filter, sort (optional)

See above for these options.

### RESPONSE

```json
    {
      "available" : [
        {
          "id" : "id-goes-here",
          "quantity" : 120.3,
          "task" : "Docked",
          "earliest_arrival" : {
            "month" : "03",
            "day" : "01",
            "hour" : "13",
            "minute" : "34",
            "second" : "15",
          },
          "details" {
            "name" : "P13",
            "mark" : "A3123AB8ED",
            "type_human" : "Fighter",
            "type" : "Fighter",
            "speed" : "1200",
            "stealth" : "1200",
            "combat" : "12000",
            "hold_size" : "0",
            "max_occupants" : "0",
            "berth_level" : "1",
            "date_started" : "01 31 2010 13:09:05 +0600",
            "date_available" : "02 01 2010 10:08:33 +0600",
            "max_occupants" : "0",
            "payload" : "{}",
            "can_scuttle" : "1",
            "can_recall" : "0",
          },
        },
        /* ... */
      ],
      "status" : { /* ... */ }
    }
```

**earliest_arrival** gives the date and time at which the fleet could arrive, if
travelling at it's top speed. Time is given as server time (UTC). (It is assumed
that no ship will take more than a year to arrive!)

## view_unavailable_fleets

Get a list of fleets that are not available to send to a specified target.

Only accepts named arguments.

    ({
      "session_id"    : "e6ebd970-7036-4aa2-a80f-1ae67109fb4e",
      "body_id"       : 23235,
      "target"        : {
          "body_name" : "Earth"
      },
      "filter"    : {
          "tag"   :  "War"
      },
      "sort"      : "combat"
    })

### session_id (required)

A session ID

### body_id (required)

The ID of the body you are sending fleets from

### target (required)

The target to send a fleet to. See above for this option.

### filter, sort (optional)

See above for these options.

### RESPONSE

```json
    {
      "unavailable" : [
        {
          "id" : "id-goes-here",
          "quantity" : 120.3,
          "task" : "Docked",
          "reason" : [
             1009,
             "Can only be sent to bodies.",
          ],
          "details" {
            "name" : "P13",
            "mark" : "A3123AB8ED",
            "type_human" : "sweeper",
            "type" : "Sweeper",
            "speed" : "14066",
            "stealth" : "15148",
            "combat" : "45522",
            "hold_size" : "0",
            "max_occupants" : "0",
            "berth_level" : "1",
            "date_started" : "01 31 2010 13:09:05 +0600",
            "date_available" : "02 01 2010 10:08:33 +0600",
            "max_occupants" : "0",
            "payload" : "{}",
            "can_scuttle" : "1",
            "can_recall" : "0",
          },
        },
        /* ... */
      ],
      "status" : { /* ... */ }
    }
```

**reason** gives the reason why the ship cannot be sent to a target, both as a numeric code
and as a human readable text string.

## view_orbiting_fleets

View orbiting fleets at the target body. At any target you will see full details of your own
or allied fleets. At any body owned by yourself or an ally you will also see foreign orbiting
fleets.

Accepts either fixed arguments or a hash of named parameters

    ( session_id, target, paging, filter, sort )
    ( parameter_hash )

### session_id (required)

A session ID

### target (required)

The target of the incoming fleets. See above for this option.

### paging, filter, sort (optional)

See above for these options.

### RESPONSE

```json
    {
      "orbiting" : [
        {
          "id" : "id-goes-here",
          "quantity" : 120.3,
          "task" : "Orbiting",
          "details" {
            "name" : "P13",
            "mark" : "A3123AB8ED",
            "type_human" : "Fighter",
            "type" : "fighter",
            "speed" : "1200",
            "stealth" : "1200",
            "combat" : "12000",
            "hold_size" : "0",
            "berth_level" : "1",
            "date_started" : "01 31 2010 13:09:05 +0600",
            "date_available" : "02 01 2010 10:08:33 +0600",
            "max_occupants" : "0",
            "payload" : "{}",
            "can_scuttle" : "0",
            "can_recall" : "0",
          },
          "to" : {
            "id" : "body-id-goes-here",
            "type" : "body",
            "name" : "mars",
            "owner" : "Foreign",
            "empire" : {
              "id" : "empire-id-here",
              "name" : "Martians"
            }
          },
          "from" : {
            "id" : "id-goes-here",
            "type" : "body",
            "name" : "Earth"
            "owner" : "Allied",
            "empire" : {
              "id" : "id-goes-here",
              "name" : "Earthlings"
            }
          },
        },
        /* ... */
      ],
      "status" : { /* ... */ }
    }
```

**owner** in the **from** and **to** section specifies either 'Own', 'Allied" or "Foreign" depending upon
who the fleet is coming from or going to.

You will only see fleets from 'Foreign' empires if the target is either your own or an allies planet, and then
the fleet information will be filtered depending upon the highest level of Spaceport on the target.

To see the `from` block :-

    SpacePort Level * 450 >= Fleet Stealth

To see the `details` block :-

    SpacePort level * 350 >= Fleet Stealth

Note that you will always see full info for your own, or allied orbiting fleets.

## view_mining_platforms

View mining platforms on the specified target (asteroid).

Accepts either fixed arguments or a hash of named parameters

    ( session_id, target )
    ( parameter_hash )

### session_id (required)

A session ID

### target (required)

The target body to check.

### RESPONSE

Show a list of all mining platforms on this asteroid.

```json
    {
      "mining_platforms" : [
        {
          empire_id   =>  "id-goes-here",
          empire_name => "The Peeps From Across The Street"
        },
        /* ... */
      ],
      "status" : { /* ... */ }
    }
```

    =head2 view_excavators

View excavators on the specified target.

Accepts either fixed arguments or a hash of named parameters

    ( session_id, target )
    ( parameter_hash )

### session_id (required)

A session ID

### target (required)

The target body to check.

### RESPONSE

Show a list of all mining platforms on this asteroid.

```json
    {
      "excavators" : [
        {
          empire_id   =>  "id-goes-here",
          empire_name => "The Peeps From Across The Street"
        },
        /* ... */
      ],
      "status" : { /* ... */ }
    }
```

## send_fleet

Send a fleet of ships to a specified target body.

Accepts either fixed arguments or a hash of named parameters

    ( session_id, fleet_id, quantity, target, arrival_date )
    ( parameter_hash )

### session_id (required)

A session ID

### fleet_id (required)

The ID of the fleet to send

### quantity (required)

The number of ships in the fleet to send.

### target (required)

The target body to check.

### arrival_date (optional)

A hash ref giving the arrival date/time
{
"soonest" : "1",
}

````

    or

```json
    {
      "month" : "08",
      "date" : "13",
      "hour" : "01",
      "minute" : "59",
      "second" : "45",
    }
````

The earliest arrival time is determined by the fleet's maximum speed,
to specify this use the **soonest** option.

If **arrival_date** is not specified then it defaults to **soonest**.

Otherwise specify the month/day/hour/minute/second for the fleet to
arrive. You cannot specify an arrival date sooner than the earliest
arrival time.

Note that the estimated arrival time in the **view_available_fleets**
call assumes that the fleet will be travelling at top speed from the
instant at which the call was made. Make allowance when setting the
arrival time for the delay between that call and this one.

The **second** can only be one of '00', '15', '30', or '45'.

Throws 1002, 1009, 1010, 1016.

### RESPONSE

```json
    {
      "status" : { /* ... */ },
      "fleet" : {

        "id" : "id-goes-here",
        "quantity" : 1,
        "task" : "Travelling",
        "details" {
          "name" : "P13",
          "mark" : "A3123AB8ED",
          "type_human" : "Probe",
          "type" : "probe",
          "speed" : "1200",
          "stealth" : "0",
          "combat" : "0",
          "hold_size" : "0",
          "berth_level" : "1",
          "date_started" : "01 31 2010 13:09:05 +0600",
          "date_available" : "02 01 2010 10:08:33 +0600",
          "max_occupants" : "0",
          "payload" : "{}",
          "can_scuttle" : "0",
          "can_recall" : "0",
        },
        "date_arrives" : "02 01 2010 10:08:33 +0600",
        "from" : {
          "id" : "id-goes-here",
          "type" : "body",
          "name" : "Earth",
          "owner" : "Allied",
          "empire" : {
            "id" : "id-goes-here",
            "name" : "Earthlings"
          }
        },
        "to" : {
          "id" : "id-goes-here",
          "type" : "star",
          "name" : "Sol",
        }
      }
    }
```

The response returns the details about the single fleet that was sent, including confirmation of
it's arrival time.

## recall_fleet

Recall all, or part of a fleet, back to it's body of origin.

Recalling an orbiting Spy Shuttle also fetches as many idle spies as will fit from the planet it was orbiting.

Throws 1002, 1010, 1013.

Accepts either fixed arguments or a hash of named parameters

    ( session_id, fleet_id, quantity )
    ( parameter_hash )

### session_id (required)

A session ID

### fleet_id (required)

The ID of the fleet to send

### quantity (required)

The number of ships in the fleet to recall

### RESPONSE

Returns the same as **view**

## recall_all

This API call is no longer supported since it will indiscriminately recall all ships, Orbiting, Defending or
Travelling.

## rename_fleet

Rename some, or all ships, in a fleet.

Accepts either positional inputs or named arguments.

    ( <session_id>, <building_id>, <fleet_id>, <name> )

    ({
      "session_id"    : "e6ebd970-7036-4aa2-a80f-1ae67109fb4e",
      "building_id"   : 23454,
      "fleet_id"      : 334133,
      "name"          : "New Name",
      "quantity"      : 3
    })

Change the name for a number of ships in a fleet

### session_id (required)

A session ID

### building_id (required)

The unique id for the space port.

### fleet_id (required)

The unique id of the fleet you want to name.

### name (required)

The name you want to give the ship. 1 to 30 characters. No profanity. No funky characters.

### quantity (optional)

The number of ships in the fleet you want to rename, defaults to all ships.

Note. this argument is only available for the named parameter calling method

If you specify a quantity less than the number of ships currently in the fleet then that
number of ships will be split off to form a new fleet with the new name. The original fleet
will retain it's original name but with a reduced number of ships.

Note also that if either fleet matches an existing fleet in all respects (attributes, task,
start/available time, name) then such fleets will be merged into a single fleet with the combined
quantity.

This gives you a means of creating or merging fleets of ships with the same attributes, just
give them different names. However, it will be much easier to manage fleets if you don't
split them in this way but allow the system to split and merge fleets based on their tasks.

### RESPONSE

Returns the same response as **view**

## scuttle_fleet

Scuttle some, or all ships, in a fleet. You can only scuttle ships that
report the **can_scuttle** status of '1'.

Accepts either positional inputs or named arguments.

    ( <session_id>, <building_id>, <fleet_id>, <quantity> )

    ({
      "session_id"    : "e6ebd970-7036-4aa2-a80f-1ae67109fb4e",
      "building_id"   : 23454,
      "fleet_id"      : 334133,
      "quantity"      : 3
    })

### session_id (required)

A session ID

### building_id (required)

This buildings ID

### fleet_id (required)

The ID of the fleet to be scuttled.

### quantity (required)

The number of ships in the fleet to be scuttled.

If you specify a quantity less than the number of ships currently in the fleet then the fleet
will be reduced by that amount. If you specify the total number of ships then the whole fleet
will be destroyed. If the fleet is damaged (it has a fractional part, e.g. 3.1) then you can
specify any whole number, or a number including the fractional part.

### RESPONSE

Returns the same response as **view**

## mass_scuttle_ship ( session_id, building_id, ship_ids )

Destroy a ship that you no longer need. It must be docked to scuttle it.

### session_id

A session id.

### building_id

The unique id for the space port.

### ship_ids

Reference to an array of ship ids

## view_travelling_fleets

Returns a list of all ships based at this colony that are currently travelling.

Accepts either fixed arguments or a hash of named parameters

    ( session_id, building_id )
    ( parameter_hash )

### session_id (required)

A session ID

### building_id (required)

This buildings ID

### paging, filter, sort (optional)

See above for these options.

### RESPONSE

```json
{
  "status": {
    /* ... */
  },
  "number_of_fleets_travelling": 30,
  "number_of_ships_travelling": 55,
  "travelling": [
    {
      "id": "id-goes-here",
      "quantity": 1,
      "type": "probe",
      "type_human": "Probe",
      "date_arrives": "01 31 2010 13:09:05 +0600",
      "from": {
        "id": "id-goes-here",
        "type": "body",
        "name": "Earth"
      },
      "to": {
        "id": "id-goes-here",
        "type": "star",
        "name": "Sol"
      }
    }
    /* ... */
  ]
}
```

The total **number_of_fleets_travelling** and the total **number_of_ships_travelling**
in those fleets are returned.

The array reference **travelling** shows each fleet and the **quantity** of ships in each fleet.

## prepare_send_spies

Gathers the information needed to call the `send_spies` method.

Accepts either fixed arguments or a hash of named parameters

    ( session_id, on_body_id, to_body_id )
    ( parameter_hash )

### session_id (required)

A session ID

### on_body_id (required)

The unique id of the planet that the spies are on and ship will be dispatched from.

### to_body_id

The unique id of the planet that the spies should be sent to. This is a required parameter
if using fixed arguments. With named arguments you can use either `to_body_id` or `to_body`

### to_body

The planet where you want to send spies to. This can be used instead of `to_body_id` if
you are using named arguments. This is a hash reference. See `target` for examples although the
target may only be an occupied Planet. (named, by ID or by x,y)

### RESPONSE

```json
{
  "status": {
    /* ... */
  },
  "fleets": [
    {
      "id": "id-goes-here",
      "quantity": 1,
      "name": "CS4",
      "hold_size": 1100,
      "speed": 400,
      "type": "cargo_ship",
      "estimated_travel_time": 3600 // in seconds
      /* ... */
    }
    /* ... */
  ],
  "spies": [
    {
      "id": "id-goes-here",
      "level": 12,
      "name": "Jack Bauer",
      "assigned_to": {
        "body_id": "id-goes-here",
        "name": "Earth"
      }
      /* ... */
    }
    /* ... */
  ]
}
```

**NOTE:** Only a certain number of spies can fit in each type of ship. Spy Pods can hold 1. Spy Shuttles can hold 4.
and ships with a cargo hold can hold 1 for every 350 units of hold size. Note however that a fleet of (say) 10 spy pods
can hold 10 spies.

## send_spies

Send one or more spies to a target using a selected fleet. See also `prepare_send_spies`

Accepts either fixed arguments or a hash of named parameters

    ( session_id, on_body_id, to_body_id, fleet_id, spy_ids )
    ( parameter_hash )

### session_id (required)

A session ID

### on_body_id (required)

The unique id of the planet that the spies are on and fleet will be dispatched from.

### to_body_id

The unique id of the planet that the spies should be sent to. This is a required parameter
if using fixed arguments. With named arguments you can use either `to_body_id` or `to_body`

### fleet_id (required)

The unique ID of the fleet. The number of ships from the fleet actually sent will depend
upon the number of spies and the number of passengers each ship can carry. The minimum number
of ships required will be sent. The rest of the fleet will stay at home.

### spy_ids (required)

An array reference of spy ids to send

### to_body

The planet where you want to send spies to. This can be used instead of `to_body_id` if
you are using named arguments. See

### arrival_date (optional)

See `send_fleet` for details. If not specified will send fleet to arrive at the soonest time.
May only be specified with the named arguments calling convention.

### RESPONSE

```json
    {
      "fleet" : {
        "id" :             "id-goes-here",
        "quantity" :       1,
        "task" :           "Travelling",
        "date_arrives" :   "02 12 2012 12:08:33 +0000",
        "details" : {
           "name" :           "CS4",
           "can_recall" :      0,
           "hold_size" :      1100,
           "speed" :          400,
           "type" :           "cargo_ship",
           "date_available" : "01 31 2010 13:09:05 +0600",
           /* ... */
        /* ... */
      },
      "spies_sent" :       ["id-goes-here","id-goes-here","id-goes-here"], // should be identical to "spy_ids"
      "spies_not_sent" :   ["id-goes-here","id-goes-here","id-goes-here"], // should only contain something if you're cheating, or a spy dies/turns between RPC calls
      "status" :           { /* ... */ }
    }
```

## prepare_fetch_spies

Gathers the information needed to call the `fetch_spies` method.

Accepts either fixed arguments or a hash of named parameters

    ( session_id, on_body_id, to_body_id)
    ( parameter_hash )

### session_id (required)

A session ID

### on_body_id

The unique id of the planet that the spies are on. This is a required parameter if using
fixed argument call. With named arguments you can either use `on_body_id` or `on_body`

### to_body_id

The unique ID of the planet to return the spies to. This is the planet from which the fleet
is sent from.

### on_body

This is an alternative way of specifying `on_body_id` using a hash ref (see `target`) but
you can only specify the ID, name or x,y of an occupied Planet. Not available when using the
fixed argument call method.

### RESPONSE

```json
{
  "status": {
    /* ... */
  },
  "fleets": [
    {
      "id": "id-goes-here",
      "name": "CS4",
      "hold_size": 1100,
      "speed": 400,
      "type": "cargo_ship",
      "estimated_travel_time": 3600 // in seconds
      /* ... */
    }
    /* ... */
  ],
  "spies": [
    {
      "id": "id-goes-here",
      "level": 12,
      "name": "Jack Bauer",
      "assigned_to": {
        "body_id": "id-goes-here",
        "name": "Earth"
      }
      /* ... */
    }
    /* ... */
  ]
}
```

## fetch_spies

Sends a specified fleet to fetch specified spies from `on_body_id` or `on_body`, and bring them
back to `to_body_id`. See also `prepare_fetch_spies`

Accepts either fixed arguments or a hash of named parameters

    ( session_id, on_body_id, to_body_id, fleet_id, spy_ids)
    ( parameter_hash )

### session_id (required)

A session ID

### on_body_id

The unique id of the planet that the spies are on. This is a required parameter if using
fixed argument call. With named arguments you can either use `on_body_id` or `on_body`

### to_body_id (required)

The unique ID of the planet to return the spies to. This is the planet from which the fleet
is sent from.

### on_body

This is an alternative way of specifying `on_body_id` using a hash ref (see `target`) but
you can only specify the ID, name or x,y of an occupied Planet. Not available when using the
fixed argument call method.

### fleet_id (required)

The unique ID of the fleet to send. The number of ships sent will be calculated based on the
number of spies to fetch and the max occupants of the ship type.

### spy_ids (required)

An array reference of unique spy IDs to fetch.
**NOTE:** If the spies are not Idle when the ship arrives, they will not be picked up.

### RESPONSE

```json
{
  "fleet": {
    "id": "id-goes-here",
    "quantity": 3,
    "name": "CS4",
    "hold_size": 1100,
    "speed": 400,
    "type": "cargo_ship",
    "date_arrives": "01 31 2010 13:09:05 +0600"
    /* ... */
  },
  "status": {
    /* ... */
  }
}
```

## view_battle_logs

Shows you the battle logs with the most recent action listed first. Data older than seven days will be cleaned out.

Accepts either fixed arguments or a hash of named parameters

    ( session_id, target, paging, filter, sort )
    ( parameter_hash )

### session_id (required)

A session ID

### building_id (required)

The ID of the space port.

### paging (optional)

See above for this option.

### RESPONSE

```json
{
  "battle_log": [
    {
      "date": "06 21 2011 22:54:37 +0600",
      "attacking_body": "Romulus",
      "attacking_empire": "Romulans",
      "attacking_unit": "Sweeper 21",
      "defending_body": "Kronos",
      "defending_empire": "Klingons",
      "defending_unit": "Shield Against Weapons",
      "victory_to": "defender"
    }
    /* ... */
  ],
  "number_of_logs": 57,
  "status": {
    /* ... */
  }
}
```
