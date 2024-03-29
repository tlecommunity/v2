---
date: 2022-10-31
type: 'page'
---

# Server Overview

A complete overview of the server statistics is available from **http://servername.lacunaexpanse.com/server_overview.json**. This file contains many statistics about the server, but not any that you could calculate using the data provided in order to keep the file small. For example, we tell you how many stars have been probed, and how many probes there are, but we don't give you the average number of probes per star, because you could calculate that yourself.

# Stats Methods

These methods are accessible via the `/stats` URL.

## credits ( )

Retrieves a list of the game credits. It is an array of hashes of arrays.

    [
       { "Game Server" : ["JT Smith"]},
       { "iPhone Client" : ["Kevin Runde"]},
       { "Web Client" : ["John Rozeske"]},
       { "Play Testers" : ["John Ottinger","Jamie Vrbsky"]},
       /* ... */
    ]

## alliance_rank ( session_id, [ sort_by, page_number ] )

Returns a sorted list of alliance ranked according to various stats.

```json
    {
       "status" : { /* ... */ },
       "alliances" : [
           {
               "alliance_id" : "id-goes-here", // unique id
               "alliance_name" : "Earthlings", // alliance name
               "member_count" : "1", // number of empires in the alliance
               "space_station_count" : 0, // number of space stations this alliance controlls
               "influence" : 0, // the number of stars under the jurisdiction of this alliance
               "colony_count" : "1", // number of planets colonized
               "population" : "7000000000", // number of citizens on all planets in the empires of the alliance
               "average_empire_size" : "7000000000", // average size of empires in the alliance
               "building_count" : "50", // number of buildings across all colonies
               "average_building_level" : "20", // average level of all buildings across all colonies
               "offense_success_rate" : "0.793", // the offense rate of success of spies at all colonies
               "defense_success_rate" : "0.49312", // the defense rate of success of spies at all colonies
               "dirtiest" : "7941"                            # the number of times a spy has attempted to hurt another empire
             },
           /* ... */
       ],
      "total_alliances" : 5939,
      "page_number" : 3
    }
```

### session_id

A session id.

### sort_by

An attribute to sort by. Defaults to `average_empire_size_rank`. Possible values are: `average_empire_size_rank`, `offense_success_rate_rank`, `defense_success_rate_rank`, and `dirtiest_rank`

### page_number

An integer representing the page number to display. There are 25 records per page. Defaults to the page number that the current user is listed on.

## find_alliance_rank ( session_id, sort_by, alliance_name )

Search for a particular alliance in the `alliance_rank()`. Returns:

```json
{
  "status": {
    /* ... */
  },
  "alliances": [
    {
      "alliance_id": "id-goes-here",
      "alliance_name": "Earth Allies",
      "page_number": "54"
    }
    /* ... */
  ]
}
```

### session_id

A session id.

### sort_by

The field to sort by. See `alliance_rank` for details.

### alliance_name

A full or partial alliance name to search by. Must be at least 3 characters to search.

## empire_rank ( session_id, [ sort_by, page_number ] )

Returns a sorted list of empires ranked according to various stats.

```json
    {
       "status" : { /* ... */ },
       "empires" : [
           {
               "empire_id" : "id-goes-here", // unique id
               "empire_name" : "Earthlings", // empire name
               "alliance_id" : "id-goes-here", // unique id
               "alliance_name" : "Earthlings Allied", // alliance name
               "colony_count" : "1", // number of planets colonized
               "population" : "7000000000", // number of citizens on all planets in the empire
               "empire_size" : "7000000000", // size of entire empire
               "building_count" : "50", // number of buildings across all colonies
               "average_building_level" : "20", // average level of all buildings across all colonies
               "offense_success_rate" : "0.793", // the offense rate of success of spies at all colonies
               "defense_success_rate" : "0.49312", // the defense rate of success of spies at all colonies
               "dirtiest" : "7941"                            # the number of times a spy has attempted to hurt another empire
             },
           /* ... */
       ],
      "total_empires" : 5939,
      "page_number" : 3
    }
```

### session_id

A session id.

### sort_by

An attribute to sort by. Defaults to `empire_size_rank`. Possible values are: `empire_size_rank`, `offense_success_rate_rank`, `defense_success_rate_rank`, and `dirtiest_rank`

### page_number

An integer representing the page number to display. There are 25 records per page. Defaults to the page number that the current user is listed on.

## find_empire_rank ( session_id, sort_by, empire_name )

Search for a particular empire in the `empire_rank()`. Returns:

```json
{
  "status": {
    /* ... */
  },
  "empires": [
    {
      "empire_id": "id-goes-here",
      "empire_name": "Earthlings",
      "page_number": "54"
    }
    /* ... */
  ]
}
```

### session_id

A session id.

### sort_by

The field to sort by. See `empire_rank` for details.

### empire_name

A full or partial empire name to search by. Must be at least 3 characters to search.

## colony_rank ( session_id, [ sort_by ] )

Returns a sorted list of planets ranked according to various stats.

```json
    {
       "status" : { /* ... */ },
       "colonies" : [
           {
               "empire_id" : "id-goes-here", // unique id
               "empire_name" : "Earthlings", // empire name
               "planet_id" : "id-goes-here", // unique id
               "planet_name" : "Earth", // name of the planet
               "population" : "7000000000", // number of citizens on planet
               "building_count" : "50", // number of buildings at this colony
               "average_building_level" : "20", // average level of all buildings at this colony
               "highest_building_level" : "26"                 # highest building at this colony
             },
           /* ... */
       ]
    }
```

### session_id

A session id.

### sort_by

An attribute to sort by. Defaults to `population_rank`. Possible values are: `population_rank`

## spy_rank ( session_id, [ sort_by ] )

Returns a sorted list of the top spies in the game ranked according to various stats.

```json
{
  "status": {
    /* ... */
  },
  "spies": [
    {
      "empire_id": "id-goes-here", // unique id
      "empire_name": "Earthlings", // empire name
      "spy_id": "id-goes-here", // unique id
      "spy_name": "Agent Null", // the name of this spy
      "age": "3693", // how old is this guy in seconds
      "level": "18", // the level of this spy
      "success_rate": "0.731", // the rate of success this spy has had for both offense and defensive tasks
      "dirtiest": "7941" // the number of times a spy has attempted to hurt another empire
    }
    /* ... */
  ]
}
```

### session_id

A session id.

### sort_by

An attribute to sort by. Defaults to `level_rank`. Possible values are: `level_rank` `success_rate_rank` and `dirtiest_rank`

## weekly_medal_winners ( session_id )

Returns a list of the empires who won this week's weekly medals.

```json
{
  "status": {
    /* ... */
  },
  "winners": [
    {
      "empire_id": "id-goes-here",
      "empire_name": "Earthlings",
      "medal_name": "Dirtiest Player In The Game",
      "medal_image": "dirtiest1",
      "times_earned": 4
    }
    /* ... */
  ]
}
```

### session_id

A session id.

```

```
