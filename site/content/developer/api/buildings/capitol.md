---
date: 2022-10-31
type: 'page'
---

# Capitol Methods

Capitol is accessible via the URL `/capitol`.

The list of methods below represents changes and additions to the methods that all [Buildings](/api/Buildings) share.

## view

This method is extended to return the cost to rename your empire

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
  "rename_empire_cost": 29
}
```

## rename_empire

Spend some essentia to rename your empire. The cost is given in the `rename_empire_cost` field
as returned by `view`

Accepts either fixed arguments or a hash of named parameters

    ( session_id, building_id, name )
    ( parameter_hash )

### session_id (required)

A session ID

### building_id (required)

This buildings ID

### name (required)

The new name of your empire

### RESPONSE

```json
{
  "status": {
    /* ... */
  }
}
```
