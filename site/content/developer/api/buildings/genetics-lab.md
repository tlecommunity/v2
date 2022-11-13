---
date: 2022-10-31
type: 'page'
---

# Genetics Lab Methods

Genetics Lab is accessible via the URL `/geneticslab`.

The list of methods below represents changes and additions to the methods that all [Buildings](/api/Buildings) share.

## prepare_experiment (session_id, building_id )

Returns everything you need to set up an experiment.

```json
{
  "status": {
    /* ... */
  },
  "grafts": [
    {
      "spy": {
        "id": "id-goes-here",
        "name": "James Bond"
        /* ... */
      },
      "species": {
        "min_orbit": 3,
        "max_orbit": 4,
        "science_affinity": 4
        /* ... */
      },
      "graftable_affinities": ["min_orbit", "management_affinity"]
    }
    /* ... */
  ],
  "survival_odds": 31,
  "graft_odds": 11,
  "essentia_cost": 2,
  "can_experiment": 1
}
```

### session_id

A session id.

### building_id

The unique id of the genetics lab.

## run_experiment ( session_id, building_id, spy_id, affinity )

Allows you to experiment on prisoners attempting to graft their genetic traits onto your own species.

```json
    {
       "experiment" : {
           "graft" : 1, // did the graft succeed
           "survive" : 0, // did the prisoner survive
           "message" : "The graft was a success, and the prisoner did not survive the experiment."
       },
       # the rest is the same as prepare_experiment
    }
```

### session_id

A session id.

### building_id

The unique id of the genetics lab.

## rename_species ( session_id, building_id, params )

Updates the empire's species name and description.

{
"success" : "1"
}

```

Throws 1000, 1005. The `data` parameter will contain the field name that needs to be adjusted, if it can be attributed to a single field.

### session_id

A session id.

### params

A hash reference of parameters.

#### name

The name of the species. Limited to 30 characters, cannot be blank, and cannot contain @, &, <, >, or ;. Required.

#### description

The species description. Limited to 1024 characters and cannot contain < or >.
```
