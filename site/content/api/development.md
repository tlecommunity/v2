---
date: 2022-10-31
type: 'page'
---

# Development Methods

Development is accessible via the URL `/development`.

The higher the development ministry, the more builds you can put in your build queue.

The list of methods below represents changes and additions to the methods that all [Buildings](/api/Buildings) share.

## view

This method is extended to include details about what's in your build queue.

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
      "building" : { /* ... */ },
      "status" : { /* ... */ },
      "build_queue" : [
        {
          "building_id" : "building-id-goes-here",
          "name" : "Planetary Commmand",
          "subsidy_cost" : 3 # the essentia cost to subsidize just this building
          "to_level" : 9,
          "seconds_remaining" : 537,
          "x" : 0,
          "y" : 0,
          "subsidy_cost" : 3 # the essentia cost to subsidize this building
        },
        {
          "building_id" : "building-id-goes-here",
          "name" : "Wheat Farm",
          "to_level" : 15,
          "seconds_remaining" : 9748,
          "x" : -1,
          "y" : 4,
          "subsidy_cost" : 5
        }
      ],
      "subsidy_cost" : 8 # the essentia cost to subsidize the whole build queue
    }
```

## subsidize_build_queue

Allows a player to instantly finish any buildings in their build queue.
The cost is returned by the `view` method.

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
  "essentia_spent": 8
}
```

## subsidize_one_build

Subsidize any one building on the build queue to be completed immediately.

Only a hash of named parameters is accepted

```json
    { parameter_hash }
```

### session_id (required)

A session ID

### building_id (required)

This buildings ID

### scheduled_id (required)

The ID of the building to subsidize

### RESPONSE

```json
{
  "status": {
    /* ... */
  },
  "essentia_spent": 2
}
```

## cancel_build

Allows a building, which is either building or scheduled to be built, to
be removed from the build queue.

Builds scheduled on the build queue after the building which is removed will
automatically be brought forward in time.

Resources scheduled for the build will not be returned.

Only a hash of named parameters is accepted

```json
    { parameter_hash }
```

### session_id (required)

A session ID

### building_id (required)

This buildings ID

### scheduled_id (optional)

The ID, or array of IDs, of the building(s) scheduled to be build/upgraded that you wish to cancel.

### cancel_all (optional)

If set to a true value, cancels all builds currently scheduled.

One of `scheduled_id` and `cancel_all` is required.

### RESPONSE

Returns the same as the `view` method.

```

```
