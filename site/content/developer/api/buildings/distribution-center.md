---
date: 2022-10-31
type: 'page'
---

# DistributionCenter Methods

The Distribution Center is accessible via the URL `/distributioncenter`.

The list of methods below represents changes and additions to the methods that all [Buildings](/api/Buildings) share.

## view ( session_id, building_id )

Same as view in [Buildings](/api/Buildings) except:

```json
    {
       "status" : { /* ... */ },
       "building" : { /* ... */ },
       "reserve" : {
           "seconds_remaining" : 0, // time until reserved resources will automatically be released
           "can" : 1,
           "max_reserve_duration" : "7200", // max length resources can be kept in reserve
           "max_reserve_size" : 100000, // max amount of resources that can be reserved
           "resources" : [ // resources currently in reserve
               {
                   "type" : "water",
                   "quanity" : 2000
               }
               {
                   "type" : "apples",
                   "quanity" : 2000
               }
           ]
       }
    }
```

## reserve ( session_id, building_id, resources )

Reserves resources so they don't get automatically spent. Resources will be held until the timer expires or manually released. Returns `view`.

Throws 1009, 1010, and 1011.

### session_id

A session id.

### building_id

The unique id of the distribution center.

### resources

An array of objects of resources you wish to reserve.

    [
        {
            "type" : "apples",
            "quanity" : 2000
        },
        {
            "type" : "chromite",
            "quantity" : 5000
        }
    ]

## release_reserve ( session_id, building_id )

Returns the resources held in reserve back to the planet.

### session_id

A session id.

### building_id

The unique id of the distribution center.

## get_stored_resources ( session_id, building_id )

Returns a list of the resources you have stored to make it easier to identify what you want to store.

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

### session_id

A session id.

### building_id

The unique id of this building.

```

```
