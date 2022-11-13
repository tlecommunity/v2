---
date: 2022-10-31
type: 'page'
---

# Ore Storage Methods

Ore Storage Tanks is accessible via the URL `/orestorage`.

Ore Storage Tanks increase the amount of ore you can store on your planet.

The list of methods below represents changes and additions to the methods that all [Buildings](/api/Buildings) share.

## view ( session_id, building_id )

This method is extended to include details about what kinds of ore are stored.

```json
{
  "building": {
    /* ... */
  },
  "status": {
    /* ... */
  },
  "ore_stored": {
    "bauxite": 0,
    "gold": 47,
    "trona": 301
    /* ... */
  }
}
```

## dump ( session_id, building_id, type, amount )

Converts ore into waste.

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

The unique id of the building.

### type

Choose a type of ore convert into waste. (gold, bauxite, galena, etc)

### amount

An integer representing the amount to dump.

```

```
