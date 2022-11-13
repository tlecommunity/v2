---
date: 2022-10-31
type: 'page'
---

# Security Methods

Security Ministry is accessible via the URL `/security`.

Captured spies are detained at the security ministry.

The list of methods below represents changes and additions to the methods that all [Buildings](/api/Buildings) share.

## view_prisoners ( session_id, building_id, [ page_number ])

Displays a list of the spies that have been captured.

```json
    {
       "status" : { /* ... */ },
       "prisoners" : [
           {
               "id"    : "id-goes-here",
               "name"  : "James Bond",
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

The unique id of the security ministry.

### page_number

Defaults to 1. Each page contains 25 spies.

## execute_prisoner ( session_id, building_id, prisoner_id )

You may choose to execute a prisoner rather than letting him serve his sentence and be released. However, that will cost you 10,000 times the prisoner's level in happiness from your planet. So a level 11 prisoner would cost you 110,000 happiness.

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

The unique id of the security ministry.

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

The unique id of the security ministry.

### prisoner_id

The unique id of a prisoner you have captured. See `view_prisoners` for details.

## view_foreign_spies ( session_id, building_id, [ page_number ])

Displays a list of the spies that are on your planet, and have a level lower than your security ministry.

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

The unique id of the security ministry.

### page_number

Defaults to 1. Each page contains 25 spies.

```

```
