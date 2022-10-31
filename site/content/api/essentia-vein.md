---
date: 2022-10-31
type: 'page'
---

# Essentia Vein Methods

Essentia Vein is accessible via the URL `/essentiavein`.

The list of methods below represents changes and additions to the methods that all [Buildings](/api/Buildings) share.

## view ( session_id, building_id )

```json
{
  "status": {
    /* ... */
  },
  "building": {
    "drain_capable": 3
    /* ... */
  }
}
```

Addition of a drain_capable flag indicating how many groups of 30 days
can be drained. Above example shows 90-119 days remaining.

## drain ( session_id, building_id, [times] )

Allows draining of an e-vein quickly. Instead of 4e per day over 30 days,
this will use up 30 days and provide 30e instantly. The optional `times`
parameter allows draining of multiple months' worth in a single RPC. Periods
less than 30 days cannot be drained quickly.
