---
date: 2022-10-31
type: 'page'
---

# Subspace Supply Depot Methods

Subspace Supply Depot is accessible via the URL `/subspacesupplydepot`.

The list of methods below represents changes and additions to the methods that all [Buildings](/api/Buildings) share.

## transmit_food ( session_id, building_id )

Convert 3600 seconds into 3600 food.

```json
{
  "building": {
    "work": {
      "seconds_remaining": 99,
      "start": "01 31 2010 13:09:05 +0600",
      "end": "01 31 2010 13:09:05 +0600"
    }
  },
  "status": {
    /* ... */
  }
}
```

### session_id

A session id.

### building_id

A building id.

## transmit_energy ( session_id, building_id )

Convert 3600 seconds into 3600 energy.

```json
{
  "building": {
    "work": {
      "seconds_remaining": 99,
      "start": "01 31 2010 13:09:05 +0600",
      "end": "01 31 2010 13:09:05 +0600"
    }
  },
  "status": {
    /* ... */
  }
}
```

### session_id

A session id.

### building_id

A building id.

## transmit_ore ( session_id, building_id )

Convert 3600 seconds into 3600 ore.

```json
{
  "building": {
    "work": {
      "seconds_remaining": 99,
      "start": "01 31 2010 13:09:05 +0600",
      "end": "01 31 2010 13:09:05 +0600"
    }
  },
  "status": {
    /* ... */
  }
}
```

### session_id

A session id.

### building_id

A building id.

## transmit_water ( session_id, building_id )

Convert 3600 seconds into 3600 water.

```json
{
  "building": {
    "work": {
      "seconds_remaining": 99,
      "start": "01 31 2010 13:09:05 +0600",
      "end": "01 31 2010 13:09:05 +0600"
    }
  },
  "status": {
    /* ... */
  }
}
```

### session_id

A session id.

### building_id

A building id.

## complete_build_queue (session_id, building_id )

Trade seconds for build queue time.

```json
{
  "building": {
    "work": {
      "seconds_remaining": 99,
      "start": "01 31 2010 13:09:05 +0600",
      "end": "01 31 2010 13:09:05 +0600"
    }
  },
  "status": {
    /* ... */
  }
}
```

### session_id

A session id.

### building_id

A building id.

```

```
