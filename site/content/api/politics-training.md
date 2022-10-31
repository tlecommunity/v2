---
date: 2022-10-31
type: 'page'
---

# PoliticsTraining Methods

Politics Training Facility is accessible via the URL `/politicstraining`.

The Politics Training Facility is where you train your spies in the dark art of social engineering.

The list of methods below represents changes and additions to the methods that all [Buildings](/api/Buildings) share.

## view ( session_id, building_id )

```json
{
  "status": {
    /* ... */
  },
  "building": {
    "spies": {
      "max_points": 2600,
      "points_per": 45,
      "in_training": 4
    }
    /* ... */
  }
}
```

### session_id

A session id.

### building_id

The unique id of your Politics Training Facility.
