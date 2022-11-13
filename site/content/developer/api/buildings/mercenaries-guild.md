---
date: 2022-10-31
type: 'page'
---

# Mercenaries Guild Methods

The Mercenaries Guild is accessible via the URL `/mercenariesguild`. It allows you to send spies to other players via spy pods. It costs essentia to use it.

The list of methods below represents changes and additions to the methods that all [Buildings](/api/Buildings) share.

## add_to_market ( session_id, building_id, spy_id, ask, [ ship_id ] )

Queues a trade for others to see. Returns:

```json
{
  "trade_id": "id-goes-here",
  "status": {
    /* ... */
  }
}
```

### session_id

A session id.

### building_id

The unique id of the mercenaries guild.

### spy_id

The unique id of the spy that you want to trade. See the `get_spies` method for a list of your spies.

### ask

An integer representing the amount of essentia you are asking for in this trade. Must be between 1 and 99.

### ship_id

Optional. The specific id of a ship you want to use for this trade. See `get_trade_ships` for details.

## get_spies ( session_id, building_id )

Returns a list of spies that may be traded. Used with the `add_trade` method.

```json
{
  "spies": [
    {
      "id": "id-goes-here",
      "name": "Jack Bauer",
      "level": "9"
    }
    /* ... */
  ],
  "cargo_space_used_each": 350,
  "status": {
    /* ... */
  }
}
```

### session_id

A session id.

### building_id

The unique id of this building.

## withdraw_from_market ( session_id, building_id, trade_id )

Remove a trade that you have offered and collect the items up for trade.

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

The unique id of this building.

### trade_id

The unique id of the trade.

## accept_from_market ( session_id, building_id, trade_id )

Accept a trade offer from the list of available trades. See `view_market`.

Throws 1016.

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

The unique id of this building.

### trade_id

The unique id of the trade.

## view_market ( session_id, building_id, [ page_number ] )

Displays a list of trades available at the present time.

```json
    {
       "trades" : [
           {
               "date_offered" : "01 31 2010 13:09:05 +0600",
               "id" : "id-goes-here",
               "ask" : 25, // essentia
               "offer" : [
                   "Level 9 spy named Jack Bauer (Mercenary Transport) Offense: 875, Defense: 875, Intel: 2, Mayhem: 0, Politics: 0, Theft: 0, Mission Count Offensive: 0 Defensive: 2)",
               ],
               "body" : {
                   "id" : "id-goes-here"         # use with get_trade_ships() to determine travel time
               },
               "empire" : {
                   "id" : "id-goes-here",
                   "name" : "Earthlings"
               }
           },
           /* ... */
       ],
       "trade_count" : 1047,
       "page_number" : 1,
       "status" : { /* ... */ }
    }
```

### session_id

A session id.

### building_id

The unique id of this building.

### page_number

Optional. An integer representing the page of trades (25 per page) to return. Defaults to 1.

## view_my_market ( session_id, building_id, [ page_number ] )

Displays a list of trades the current user has posted.

```json
{
  "trades": [
    {
      "date_offered": "01 31 2010 13:09:05 +0600",
      "id": "id-goes-here",
      "ask": 25, // essentia
      "offer": [
        "Level 9 spy named Jack Bauer (Mercenary Transport) Offense: 875, Defense: 875, Intel: 2, Mayhem: 0, Politics: 0, Theft: 0, Mission Count Offensive: 0 Defensive: 2)"
      ]
    }
    /* ... */
  ],
  "trade_count": 17,
  "page_number": 1,
  "status": {
    /* ... */
  }
}
```

### session_id

A session id.

### building_id

The unique id of this building.

### page_number

An integer representing the page of trades (25 per page) to return. Defaults to 1.

## get_trade_ships ( session_id, building_id, [ target_body_id ] )

Returns a list of the ships that could be used to do a trade.

```json
{
  "status": {
    /* ... */
  },
  "ships": [
    {
      "id": "id-goes-here",
      "type": "spy_pod",
      "name": "Spy Pod 5",
      "estimated_travel_time": 3600 // in seconds, one way
      /* ... */
    }
    /* ... */
  ]
}
```

### session_id

A session id.

### building_id

The unique id of the trade ministry.

### target_body_id

The unique id of the body you'll be shipping to. Optional. If included it will calculate the estimated travel time of the ships to this body.

## report_abuse ( session_id, building_id, trade_id )

Report a trade that you think is abusing the trade system.

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

The unique id of this building.

### trade_id

The unique id of the trade.

```

```
