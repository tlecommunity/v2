---
date: 2022-10-31
type: 'page'
---

# Mission Command Methods

Mission Command is accessible via the URL `/missioncommand`.

The list of methods below represents changes and additions to the methods that all [Buildings](/api/Buildings) share.

## get_missions ( session_id, building_id )

Returns a list of missions that you are eligible to complete in this zone.

```json
{
  "status": {
    /* ... */
  },
  "missions": [
    {
      "id": "id-goes-here",
      "max_university_level": 12,
      "date_posted": "01 31 2010 13:09:05 +0600",
      "name": "The Big Mission",
      "description": "Do the big thing and make it go.",
      "objectives": ["1500 apple", "Kill a spy", "Destroy a ship"],
      "rewards": ["1 essentia"]
    }
    /* ... */
  ]
}
```

**NOTE:** This is not the complete list of missions in the zone. You cannot complete missions you've already completed, nor can you complete missions that are registered as being below your university level.

### session_id

A session id.

### building_id

The unique id for the mission command building.

## complete_mission ( session_id, building_id, mission_id )

Completes a mission. Will be rejected if you do not have all the objectives met. If you have met the objectives, then the rewards will be distributed to you.

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

The unique id for the mission command building.

### mission_id

The unique id of the mission you'd like to complete.

## skip_mission ( session_id, building_id, mission_id )

Skips a mission. This mission won't show up on the list of missions for this user for 30 days.

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

The unique id for the mission command building.

### mission_id

The unique id of the mission you'd like to skip.

```

```
