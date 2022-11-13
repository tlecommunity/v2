---
date: 2022-10-31
type: 'page'
---

# Library of Jith Methods

Library of Jith is accessible via the URL `/libraryofjith`.

The list of methods below represents changes and additions to the methods that all [Buildings](/api/Buildings) share.

## research_species (session_id, building_id, empire_id )

Returns a list of species stats for any species in the game.

```json
{
  "species": {
    "name": "Human",
    "description": "The descendants of Earth.",
    "min_orbit": 3,
    "max_orbit": 3,
    "manufacturing_affinity": 4,
    "deception_affinity": 4,
    "research_affinity": 4,
    "management_affinity": 4,
    "farming_affinity": 4,
    "mining_affinity": 4,
    "science_affinity": 4,
    "environmental_affinity": 4,
    "political_affinity": 4,
    "trade_affinity": 4,
    "growth_affinity": 4
  },
  "status": {
    /* ... */
  }
}
```

### session_id

A session id.

### building_id

The unique id of this building.

### empire_id

The unique id of an empire you'd like to know more about. See ["find" in Empire](/api/Empire#find) to turn a name into an id.

```

```
