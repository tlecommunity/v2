---
date: 2022-10-31
type: 'page'
---

# Theme Park Methods

Theme Park is accessible via the URL `/themepark`.

The list of methods below represents changes and additions to the methods that all [Buildings](/api/Buildings) share.

## view ( session_id, building_id )

This method is changed from the default because it adds a `themepark` element to the output.

```json
{
  "building": {
    /* ... */
  },
  "status": {
    /* ... */
  },
  "themepark": {
    "food_type_count": 12,
    "can_operate": 0,
    "reason": [
      1011,
      "This Theme Park was started with 12 types of food so you need at least 12 types of food to continue its operation."
    ]
  }
}
```

Consult the `work` block to see how long the Theme Park will remain in operation.

### session_id

A session id.

### building_id

The unique id of the park.

## operate ( session_id, building_id )

Initiates operation of the Theme Park. You need at least 1,000 of each of 5 food types to start the Theme Park for one hour. Once the Theme Park starts it will start using a lot more resources, but it will also start outputting large amounts of happiness. The amount of happiness generated is directly proportional to the number of food types used to start the Theme Park, and is also expontentially increased with each level of the Theme Park.

While the Theme Park is operating, you can call this method again to spend more food and increase the duration of operation of the Theme Park. However, you must be able to spend at least as much food as you did when this method was last called.

Returns `view`.

Throws 1002, 1006, 1010, and 1011.

### session_id

A session id.

### building_id

The unique id of the theme park.
