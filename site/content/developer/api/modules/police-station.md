---
date: 2022-10-31
type: 'page'
---

# Police Station Methods

Police Station is accessible via the URL `/policestation`.

Captured spies are detained at the Police Station.

The list of methods below represents changes and additions to the methods that all [Buildings](/api/Buildings) share.

## view_prisoners ( session_id, building_id, [ page_number ])

Displays a list of the spies that have been captured.

```json
    {
       "status" : { /* ... */ },
       "prisoners" : [
           {
               "id" : "id-goes-here",
               "name" : "James Bond",
               "level" : "20",
               "task"  : "Captured" or "Prisoner Transport",
               "sentence_expires" : "01 31 2010 13:09:05 +0600"
           },
           /* ... */
       ]
    }
```

### session_id

A session id.

### building_id

The unique id of the Police Station.

### page_number

Defaults to 1. Each page contains 25 spies.

## execute_prisoner ( session_id, building_id, prisoner_id )

You may choose to execute a prisoner rather than letting him serve his sentence and be released.

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

The unique id of the Police Station.

### prisoner_id

The unique id of a prisoner you have captured. See `view_prisoners` for details.

## release_prisoner ( session_id, building_id, prisoner_id )

You may choose to release a prisoner by calling this method.

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

The unique id of the Police Station.

### prisoner_id

The unique id of a prisoner you have captured. See `view_prisoners` for details.

## view_foreign_spies ( session_id, building_id, [ page_number ])

Displays a list of the spies that are on your planet, and have a level lower than your Police Station.

```json
{
  "status": {
    /* ... */
  },
  "spies": [
    {
      "name": "James Bond",
      "level": 11,
      "task": "Appropriate Technology",
      "next_mission": "01 31 2010 13:09:05 +0600"
    }
    /* ... */
  ]
}
```

### session_id

A session id.

### building_id

The unique id of the Police Station.

### page_number

Defaults to 1. Each page contains 25 spies.

## view_foreign_ships ( session_id, building_id, page_number )

Shows you all the foreign ships that are incoming. However, the list is filtered by the stealth of the ship vs the level of the Police Station. The formula is:

    525 * Police Station Level >= Ship Stealth

If your Police Station exceeds the Ship's Stealth, then you'll see it incoming. Otherwise you won't.

```json
{
  "ships": [
    {
      "id": "id-goes-here",
      "name": "CS3",
      "type_human": "Cargo Ship",
      "type": "cargo_ship",
      "date_arrives": "02 01 2010 10:08:33 +0600",
      "from": {
        "id": "id-goes-here",
        "name": "Earth",
        "empire": {
          "id": "id-goes-here",
          "name": "Earthlings"
        }
      }
    }
    /* ... */
  ],
  "number_of_ships": 13,
  "status": {
    /* ... */
  }
}
```

The `from` block is only included if

    675 * Police Station Level >= Ship Stealth

### session_id

A session id.

### building_id

The unique id of the space port.

### page_number

Defaults to page 1. Shows 25 at a time.

## view_ships_travelling ( session_id, building_id, [ page_number ])

Returns a list of the ships that are travelling to or from this planet.

**NOTE:** All inbound/outbound ships are shown regardless of which space port they will eventually land at.

```json
{
  "status": {
    /* ... */
  },
  "number_of_ships_travelling": 30,
  "ships_travelling": [
    {
      "id": "id-goes-here",
      "type": "probe",
      "type_human": "Probe",
      "date_arrives": "01 31 2010 13:09:05 +0600",
      "from": {
        "id": "id-goes-here",
        "type": "body",
        "name": "Earth"
      },
      "to": {
        "id": "id-goes-here",
        "type": "star",
        "name": "Sol"
      }
    }
    /* ... */
  ]
}
```

### session_id

A session id.

### building_id

The unique id of the space port.

### page_number

Defaults to 1. An integer representing which page of ships travelling to view. Each page shows 25 ships.

## view_ships_orbiting ( session_id, building_id, [ page_number ])

Shows you all the foreign ships that are orbiting this planet. However, the list is filtered by the stealth of the ship vs the level of the Police Station. The formula is:

    525 * Police Station Level >= Ship Stealth

If your Police Station exceeds the Ship's Stealth, then you'll see it orbiting. Otherwise you won't.

```json
{
  "ships": [
    {
      "id": "id-goes-here",
      "name": "SS3",
      "type": "spy_shuttle",
      "type_human": "Spy Shuttle",
      "date_arrived": "02 01 2010 10:08:33 +0600",
      "from": {
        "id": "id-goes-here",
        "name": "Mars",
        "empire": {
          "id": "id-goes-here",
          "name": "Martians"
        }
      }
    },
    {
      "id": "id-goes-here",
      "name": "F3",
      "type": "fighter",
      "type_human": "Fighter",
      "from": {
        "id": "id-goes-here",
        "name": "Earth",
        "empire": {
          "id": "id-goes-here",
          "name": "Earthlings"
        }
      }
    }
    /* ... */
  ],
  "number_of_ships": 13,
  "status": {
    /* ... */
  }
}
```

The `from` block is only included if

    675 * Police Station Level >= Ship Stealth

### session_id

A session id.

### building_id

The unique id of the space port.

### page_number

Defaults to page 1. Shows 25 at a time.

```

```
