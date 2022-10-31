---
date: 2022-10-31
type: 'page'
---

# Waste Recycling Methods

Waste Recycling Center is accessible via the URL `/wasterecycling`.

The Waste Recycling Center can be used to convert waste in storage into usable resources.

The list of methods below represents changes and additions to the methods that all [Buildings](/api/Buildings) share.

## view ( session_id, building_id )

```json
{
  "status": {
    /* ... */
  },
  "building": {
    /* ... */
  },
  "recycle": {
    "seconds_remaining": 0,
    "can": 1,
    "seconds_per_resource": "2.138", // to precalculate the time recycling will take
    "max_recycle": 12000,
    "water": 0,
    "energy": 0,
    "ore": 0
  }
}
```

## recycle ( session_id, building_id, water, ore, energy, use_essentia )

Converts waste into water, ore, and energy. You can choose which amounts of each you want, so long as their total does not go over the amount of waste you have on hand. For each unit of waste converted, the recycling center will take 10 seconds to complete the recycling process. However, the amount of time is reduced a bit by the level of the Recycling Center. Returns `view`.

Throws 1010 and 1011.

### session_id

A session id.

### building_id

The unique id of the Waste Recycling Center.

### water

An integer representing the amount of water you want.

### ore

An integer representing the amount of ore you want.

### energy

An integer representing the amount of energy you want.

### use_essentia.

Defaults to 0. A boolean indicating that you wish to spend 2 essentia, to have the recycling operation completed immediately.

## subsidize_recycling ( session_id, building_id )

Will spend 2 essentia to complete the current recycling job immediately. Returns `view`.

Throws 1011.

### session_id

A session id.

### building_id

The unique id of the waste recycling building.

```

```
