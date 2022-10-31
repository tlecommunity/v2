---
date: 2022-10-31
type: 'page'
---

# Network19 Methods

Network 19 Affiliate is accessible via the URL `/network19`.

Network 19 is the news network covering the Expanse. Here you can learn all kinds of things about what's happening around you, without even leaving your planet. Every two levels you'll receive news from additional zones around you, up to 7 total zones.

The list of methods below represents changes and additions to the methods that all [Buildings](/api/Buildings) share.

## view (session_id, building_id)

```json
    {
       "status" : { /* ... */ },
       "building" : { /* ... */ },
       "restrict_coverage" : 1 # see restrict_coverage()
    }
```

## restrict_coverage ( session_id, building_id, onoff )

You can enact or disband a policy to restrict what Network 19 covers about your planet. Restricting coverage does make your citizens unhappy.

```json
{
  "status": {
    /* ... */
  }
}
```

Throws 1009.

### session_id

A session id.

### building_id

The unique id of this Network 19 Affiliate.

### onoff

A boolean indicating whether or not you have enacted a policy to restrict coverage. 1 to restrict, 0 to not restrict.

## view_news ( session_id, building_id )

Get the top 100 headlines from your region of space (called a zone). It also returns a list of RSS feeds that can be used outside the game to see the same news in a given zone.

```json
{
  "news": [
    {
      "headline": "HCorp founded a new colony on Rigel 4.",
      "date": "01 31 2010 13:09:05 +0600"
    }
    /* ... */
  ],
  "feeds": {
    "0|0|0": "http://feeds.game.lacunaexpanse.com/78d5e7b2-b8d7-317c-b244-3f774264be57.rss"
  },
  "status": {
    /* ... */
  }
}
```

### session_id

A session id.

### building_id

The unique id of the Network 19 Affiliate.

```

```
