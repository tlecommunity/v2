---
date: 2022-10-31
type: 'page'
---

# Food Reserve Methods

Food Reserve is accessible via the URL `/foodreserve`.

The food reserve stores the excess food you produce.

The list of methods below represents changes and additions to the methods that all [Buildings](/api/Buildings) share.

## view ( session_id, building_id )

This method is extended to include details about what kind of food is stored.

```json
{
  "building": {
    /* ... */
  },
  "status": {
    /* ... */
  },
  "food_stored": {
    "apple": 0,
    "bread": 47,
    "algae": 301
    /* ... */
  }
}
```

## dump ( session_id, building_id, type, amount )

Converts food into waste.

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

Choose a type of food convert into waste. (apple, corn, burger, etc)

### amount

An integer representing the amount to dump.

```

```
