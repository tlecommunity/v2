---
date: 2022-10-31
type: 'page'
---

# Black Hole Generator Methods

Black Hole Generator is accessible via the URL `/blackholegenerator`.

The list of methods below represents changes and additions to the methods that all [Buildings](/api/Buildings) share.

## view

This method is extended to include the list of tasks.

Accepts either fixed arguments or a hash of named parameters

    ( session_id, building_id )
    ( parameter_hash )

Throws 1002, 1009, 1010, 1013

## generate_singularity

Note: this method call now supports both the fixed argument list and the new
named argument call method (to be introduced into V4.000). For backwards compatibility
the original fixed argument list will continue to be supported but will not support
any new arguments (in this case the subsidize option). You will need to use the named
argument calling convention if you want to subsidize the BHG and achieve 'perfection'.

### fixed argument list (original calling method)

    session_id, building_id, target, task_name, [ params ]

### named arguments

```json
{
  "session_id": "329da49c-7e88-4897-9d8c-3e5f6309d9b7",
  "building_id": 124333,
  "target": { "body_name": "mars" },
  "task_name": "Change Type",
  "params": { "newtype": 33 },
  "subsidize": 1
}
```

Note that named arguments can be in any order. If optional then they can be omitted
the `subsidize` argument will cost E to achieve 'perfection' of 100% reliability, if
omitted then you accept the risk of failure.

### session_id (required)

A session ID

### building_id (required)

This buildings ID

### RESPONSE

```json
    {
     "status" : { /* ... */ },
     "building" : { /* ... */ },
     "tasks" : [
       {
         "base_fail" : 15, //Note, range is not factored in.
         "min_level" : 10,
         "name" : "Make Asteroid",
         "occupied" : 0,
         "recovery" : 129600,
         "side_chance" : 10,
         "types" : [
           "habitable planet",
           "gas giant"
         ],
         "waste_cost" : 50000000
         "reason" : "You can only make an asteroid from a planet."
       },/* ... */
     ]
    }
```

## generate_singularity

Accepts either fixed arguments or a hash of named parameters

    ( session_id, building_id )
    ( parameter_hash )

Throws 1002, 1009, 1010, 1013

### session_id (required)

A session ID

### building_id (required)

This buildings ID

### target (required)

A hash reference that can contain one of three items to identify a body.

```json
    { "body_name" : "Earth" }
    { "body_id" : "id-goes-here" }
    { "x" : 4, "y" : -3 }
```

#### body_name

A string with the body's name. Case insensitive, but will throw an exception for misspelling.

#### body_id

The unique id of the body.

#### x | y

A set of x,y coordinates to locate the star or body.

#### star_name

A string with the star's name. Case insensitive, but will throw an exception for misspelling.

#### star_id

The unique id of the star.

#### orbit

If star_name or star_id are given, an extra "orbit" parameter is allowed.
This allows easier specifying of unoccupied orbits. If not given, then
the target remains the star, otherwise the target is the given position,
whether occupied or not, about the given star.

#### zone

Zone name as a target. ie: '-1|4' ; Only useful for Jump Zone.

### task_name (required)

The Task that the BHG is to perform. One of.

- Make Asteroid

  Can convert any non-inhabited planet to a random asteroid. Initial size is determined by level of BHG. Usable at Black Hole Generator level 10.

- Make Planet

  Can convert any non-inhabited asteroid (no platforms) to a size 30 planet of random type. Usable at Black Hole Generator level 15.

- Increase Size

  Can increase the size of a habitable planet up to size 65 or an asteroid up to size 10. Usable at Black Hole Generator level 20.

- Change Type

  Can change the type of a habitable planet to any of the basic 40 types. Usable at Black Hole Generator level 25.

  Only allowed to change occupied planets that share your alliance.

- Swap Places

  Can swap places with another body within range. Usable at Black Hole Generator level 30.

- Jump Zone

  Target is a zone, BHG planet swaps with a random unoccupied habitable in target zone. Usable at level 15.

- Move System

  Moves entire system of bodies to target star. Moves bodies at target star to origin. Target star needs to not be occupied by another alliance and not seized by another alliance.

### params (only required for `Change Type`)

```json
{ "newtype": 20 }
```

### RESPONSE

Returns success, failure, and side effect results.

```json
    {
     "status" : { /* ... */ },
     "fail" : { /* ... */ },
     "side" : { /* ... */ },
     "target" : {
       "class" : "Lacuna::DB::Result::Map::Body::Asteroid::A2",
       "id" : "body id",
       "name" : "name of planet effected",
       "old_class" : "Lacuna::DB::Result::Map::Body::Planet::P9",
       "old_size" : Size before change,
       "message" : "Made Asteroid",
       "size" : Size of body after effect
       "type" : "asteroid", "gas giant", "habitable planet", or "space station"
       "variance" : -1, 0, or 1
       "waste" : "Zero", "Random", or "Filled"
     }
    }
```

Not all fields are used for every result or task.

Failure rates for the Blackhole Generator increases with range.

Side Effects happen fairly randomly, but occur more often the more difficult the task.

## get_actions_for

Get a task list with success percentage for defined target.

Accepts either fixed arguments or a hash of named parameters

    ( session_id, building_id )
    ( parameter_hash )

Throws 1002, 1009, 1010, 1013

### session_id (required)

A session ID

### building_id (required)

This buildings ID

### target (required)

A hash reference that can contain one of three items to identify a body.

```json
    { "body_name" : "Earth" }
    { "body_id" : "id-goes-here" }
    { "x" : 4, "y" : -3 }
```

### RESPONSE

```json
    {
     "status" : { /* ... */ },
     "building" : { /* ... */ },
     "tasks" : [
       {
         "base_fail" : 15,
         "body_id" : 973213,
         "dist" : 134.40,
         "min_level" : 10,
         "name" : "Make Asteroid",
         "occupied" : 0,
         "range" : 150,
         "reason" : "You can only make an asteroid from a planet."
         "recovery" : 129600,
         "side_chance" : 25,
         "success" : 0,
         "throw" : 1009,
         "types" : [
           "habitable planet",
           "gas giant"
         ],
         "waste_cost" : 50000000
       },/* ... */
     ]
    }
```

Options are as described for generate_singularity

**cost** is the amount in Essentia which will make the task 'perfect' (i.e. 100% success) the lower
the probability of success, the higher the cost. The minimum is 2E.

If **name** is **Change Type**, a **body_type** parameter is provided which will be either
**asteroid** or **habitable planet**.

If the chance of success is zero, then no amount of Essentia will make it succeed.

## subsidize_cooldown ( session_id, building_id )

Will spend 2 essentia to cool down the BHG immediately. Returns `view`.

Throws 1011.

### session_id

A session id.

### building_id

The unique id of the Black Hole Generator.

```

```
