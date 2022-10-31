---
date: 2022-10-31
type: 'page'
---

# MayhemTraining Methods

Mayhem Training Facility is accessible via the URL `/mayhemtraining`.

The Mayhem Training Facility is where you train your spies in the art of destruction.

The list of methods below represents changes and additions to the methods that all [Buildings](/api/Buildings) share.

## view ( session_id, building_id )

{
"status" : { /_ ... _/ },
"building" : {
"spies" : {
"max*points" : 2600,
"points_per" : 45,
"in_training" : 4,
},
/* ... \_/
},
}

```

### session_id

A session id.

### building_id

The unique id of your Mayhem Training Facility.
```
