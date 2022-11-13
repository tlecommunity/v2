---
date: 2022-10-31
type: 'page'
---

# Entertainment District Methods

The Entertainment District is accessible via the URL `/entertainment`.

The list of methods below represents changes and additions to the methods that all [Buildings](/api/Buildings) share.

## view ( session_id, building_id )

Same as view in [Buildings](/api/Buildings) except:

```json
{
  "status": {
    /* ... */
  },
  "ducks_quacked": 493
}
```

## get_lottery_voting_options ( session_id, building_id )

This is the starting point to a voting lottery system. The user can vote on a site once and only once per day and each vote enters him/her into a lottery. At the end of the day a lottery ticket will be drawn, and a winner will be chosen to receive 10 essentia. Every vote is equal, but the more votes you have the greater your odds of winning.

Returns a list of sites that the user can vote on.

```json
{
  "options": [
    {
      "name": "Some Site",
      "url": "http://www.somesite.com/vote?id=44"
    }
    /* ... */
  ],
  "status": {
    /* ... */
  }
}
```

**NOTE:** The URLs returned in the `url` parameter need to be opened into a new browser window so that the user can go vote on a remote site.

Each `url` is usable only once every 24 hours. The server keeps track of this, but the client must remove the URL from the list after the user has clicked on it so they know not to click again.

### session_id

A session id.

### building_id

The unique id of the entertainment district.

## duck_quack ( session_id, building_id )

Returns a string that must retain its formatting (whitespace and carriage returns) when displayed to the user.

```json
{
  "quack": "quack text",
  "status": {
    /* ... */
  }
}
```

### session_id

A session id.

### building_id

The unique id of this building.

```

```
