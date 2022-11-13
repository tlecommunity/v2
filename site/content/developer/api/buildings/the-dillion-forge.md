---
date: 2022-10-31
type: 'page'
---

# The Dillon Forge Methods

The Dillon Forge is accessible via the URL `/thedillonforge`.

The list of methods below represents changes and additions to the methods that all [Buildings](/api/Buildings) share.

## view ( session_id, building_id )

This method is extended to include the list of tasks.

```json
    {
       "status " : { /* ... */ },
       "building" : { /* ... */ },
       "tasks" : {
         "current_task" : "make_plan",
         "seconds_remaining" : 120,
         "can" : 0,
         "working" : "Making Crater 6+0",
         "subsidy_cost" : 2,

         "make_plan" : [
           {
             "name" : "Algae",
             "max_level" : 10,
             "class" : "Food::Algae",
             "reset_sec_per_level" : 5000,
           },/* ... */
         ],
         "split_plan" : [
           {
             "name" : "Beach [10]",
             "class" : "Permanent::Beach10",
             "level" : 1,
             "extra_build_level" : 2,
             "fail_chance" : 50,
             "reset_seconds",
           },/* ... */
         ]
       }
    }
```

## make_plan ( session_id, building_id, plan_class, level )

### session_id

A session id.

### building_id

The unique id of the Dillon Forge.

### plan_class

The class of the plan, as returned in the **view** method

### level

The level to build the plan. Note that The Dillon Forge can only build plans
up to the level of the building. A level 10 Dillon Forge can build any plan level
from 2+0 to 10+0. There must be at least 2x level 1+0 plans on a colony of the
specified class to build a level x+0 plan.

The **seconds_per_level** is how long it will take to build a plan per level.

## split_plan ( session_id, building_id, plan_class, level, extra_build_level, quantity )

Split a plan into it's constituant glyphs. The glyph types that can be returned
depend upon the recipe to build that type of plan. The maximum number of glyphs
that can be returned depend upon the number of glyphs in the recipe for a level
1+0 plan, the level of the plan being split and the extra build levels.

The **fail_chance** given in the view method, determines the number of glyphs that
are likely to be returned. For example, if a plan is 'worth' 4 glyphs then, on
average, a 50% fail_chance will return 2 glyphs (chosen at random from all glyph
types that make up the plan.

The **fail_chance** is determined by the level of The Dillon Forge and is 3% per
level of the building.

### session_id

A session id.

### building_id

The unique id of the Dillon Forge.

### plan_class

The class of the plan, as returned in the **view** method

### level

The level of the plan to be split.

### extra_build_level

The extra build levels (if any) for that plan.

### quantity

Number of plans to feed into the forge. Time does not go up linearly, but the more plans fed in, the more efficient.

## subsidize ( session_id, building_id )

Will spend essentia to complete the current task immediately. Cost is 2e unless splitting multiple plans. Returns **view**

Throws 1011.

### session_id

A session id.

### building_id

The unique id of the Dillon Forge.

```

```
