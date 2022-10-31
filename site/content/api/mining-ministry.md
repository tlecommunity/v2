---
date: 2022-10-31
type: 'page'
---

# Mining Ministry Methods

Mining Ministry is accessible via the URL `/miningministry`.

The Mining Ministry controls mining platform ships for harvesting the resources of asteroids.

The list of methods below represents changes and additions to the methods that all [Buildings](/api/Buildings) share.

## view_platforms ( session_id, building_id )

Returns a list of the mining platforms currently controlled by this ministry.

```json
{
  "status": {
    /* ... */
  },
  "max_platforms": 1,
  "platforms": [
    {
      "id": "id-goes-here",
      "asteroid": {
        "id": "id-goes-here",
        "name": "Kuiper",
        "x": 0,
        "y": -444,
        "image": "a1-5"
        /* ... */
      },
      "rutile_hour": 10,
      "chromite_hour": 10,
      "chalcopyrite_hour": 10,
      "galena_hour": 10,
      "gold_hour": 10,
      "uraninite_hour": 10,
      "bauxite_hour": 10,
      "goethite_hour": 10,
      "halite_hour": 10,
      "gypsum_hour": 10,
      "trona_hour": 10,
      "kerogen_hour": 10,
      "methane_hour": 10,
      "anthracite_hour": 10,
      "sulfur_hour": 10,
      "zircon_hour": 10,
      "monazite_hour": 10,
      "fluorite_hour": 10,
      "beryl_hour": 10,
      "magnetite_hour": 10,
      "shipping_capacity": 51
    }
    /* ... */
  ]
}
```

The `shipping_capacity` number is a percent which gives you an indication of your production vs shipping efficiency. If it's a -1 then you have no ships servicing the platforms. If it's at 0, then it means you have ships but no production. If it's 1 to 99 then you've got more shipping capacity than production. If it's at 100 then everything is in harmony. And if it's greater than 100 then you need to add ships because you're producing more than your ships can handle.

### session_id

A session id.

### building_id

The unique id of the mining ministry.

## view_ships ( session_id, building_id )

Shows you the ships that are working in the mining fleet, and available to work in the mining fleet.

```json
{
  "ships": [
    {
      "name": "CS4",
      "id": "id-goes-here",
      "task": "Mining",
      "speed": 350,
      "hold_size": 5600
    }
    /* ... */
  ],
  "status": {
    /* ... */
  }
}
```

### session_id

A session id.

### building_id

The unique id of the mining ministry.

## add_cargo_ship_to_fleet ( session_id, building_id, ship_id )

Take a cargo ship from the space port and add it to the mining fleet.

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

The unique id of the mining ministry.

### ship_id

The unique id of the ship you want to add to the fleet.

## remove_cargo_ship_from_fleet ( session_id, building_id, ship_id )

Tell one of the cargo ships in the mining fleet to come home and park at the space port.

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

The unique id of the mining ministry.

### ship_id

The unique id of the ship you want to add.

## abandon_platform ( session_id, building_id, platform_id )

Close down an existing mining platform.

```json
{
  "status": {
    /* ... */
  }
}
```

Throws 1002.

### session_id

A session id.

### building_id

The unique id of the mining ministry.

### platform_id

The unique id of the platform you wish to abandon.

## mass_abandon_platform ( session_id, building_id )

Destroy all platforms.

### session_id

A session id.

### building_id

The unique id for the mining ministry.

```

```
