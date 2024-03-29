---
date: 2022-10-31
type: 'page'
---

# Park Methods

Park is accessible via the URL `/park`.

Parks are highly useful because they generate happiness for your planet. Just being able to use the park makes your citizens happy, but you can also throw parties for them, which will generate lots of happiness at the end of the party.

The list of methods below represents changes and additions to the methods that all [Buildings](/api/Buildings) share.

## view ( session_id, building_id )

This method is changed from the default because it adds a `party` element to the output.

```json
{
  "building": {
    /* ... */
  },
  "status": {
    /* ... */
  },
  "party": {
    "seconds_remaining": 397,
    "happiness": 10000,
    "can_throw": 0
  }
}
```

If there's an ongoing party you'll be able to see how long it has left. And if there's not a party it will let you know whether you have the resources to throw one.

### session_id

A session id.

### building_id

The unique id of the park.

## throw_a_party ( session_id, building_id )

Initiates a party. It will cost you 10,000 food, and the party will last for a day. For 10,000 food you'll get 3,000 happiness. For each type of food available in quantities of 500 or more, you'll get a multiplier added to that. So if you have 4 types of food, you'll get 12,000 happiness. In addition, you get a 0.3 to your multiplier for each level of park that you have. Therefore a level 10 park is the same as adding three extra foods to your party!

Returns `view`.

Throws 1002, 1006, 1010, and 1011.

### session_id

A session id.

### building_id

The unique id of the park.

## subsidize_party ( session_id, building_id )

Will spend 2 essentia to complete the current party immediately. Returns `view`.

Throws 1011.

### session_id

A session id.

### building_id

The unique id of the Park.

```

```
