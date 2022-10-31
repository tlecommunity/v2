---
date: 2022-10-31
type: 'page'
---

# Space Station Lab Methods

Space Station Lab is accessible via the URLs `/ssla`, `/sslb`, `/sslc`, and `/ssld`. The `/ssla` URL controls all the actual functions of the lab, but you must build all four lab components to use the functions of SSL A.

The list of methods below represents changes and additions to the methods that all [Buildings](/api/Buildings) share.

**NOTE:** These methods and changes have only been made to `/ssla`.

## view ( session_id, building_id )

This method is changed from the default because it adds a `make_plan` element to the output.

```json
    {
       "building" : { /* ... */ },
       "status" : { /* ... */ },
       "make_plan" : {
           "types" : [
               {
                   "type" : "ibs",
                   "name" : "Interstellar Broadcast Station",
                   "image" : "ibs",
                   "url" : "/ibs"
               },
               /* ... */
           ],
           "level_costs" : [
               {
                  level    => 1,
                  food     => 10000,
                  ore      => 10000,
                  water    => 10000,
                  energy   => 10000,
                  waste    => 2500,
                  time     => 1200
               },
               /* ... */
           ],
           "subsidy_cost" : 2,
           "making" : "Interstellar Broadcast Station (3+0)"
       }
    }
```

If there is a plan being made then the `making` element will be present.

### session_id

A session id.

### building_id

The unique id of the space station lab.

## make_plan ( session_id, building_id, type, level )

Starts the plan creation process.

Returns `view`.

### session_id

A session id.

### building_id

The unique id of the space station lab.

### type

The key from the hash returned by the `view` method in make_plan > types. For example, `ibs` for "Interstellar Broadcast Station".

### level

An integer between 1 and 30. The level from the array returned by the `view` method in make_plan > level_costs.

## subsidize_plan ( session_id, building_id )

Will spend essentia equal to the subsidy_cost returned by the `view` method to complete the current plan immediately. Returns `view`.

Throws 1011.

### session_id

A session id.

### building_id

The unique id of the space station lab.

```

```
