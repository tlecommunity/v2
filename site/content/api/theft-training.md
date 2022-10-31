---
date: 2022-10-31
type: 'page'
---

# TheftTraining Methods

Theft Training Facility is accessible via the URL `/thefttraining`.

The Theft Training Facility is where you train your spies in the art of appropriation.

The list of methods below represents changes and additions to the methods that all [Buildings](/api/Buildings) share.

## view ( session_id, building_id )

```json
{
  "status": {
    /* ... */
  },
  "building": {
    "spies": {
      "max*points": 2600,
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

The unique id of your Theft Training Facility.
