---
date: 2022-10-31
type: 'page'
---

# Embassy Diagram

The Embassy is a complex beast, so to help you wrap your brain around it we've created a little flow diagram of how the methods come together.

![Embassy](embassy.png)

# Embassy Methods

Embassy is accessible via the URL `/embassy`. The embassy is used to form alliances with other players.

The list of methods below represents changes and additions to the methods that all [Buildings](/api/Buildings) share.

## view ( session_id, building_id )

Same as view in [Buildings](/api/Buildings) except:

```json
    {
       "status" : { /* ... */ },
       "building" : { /* ... */ },
       "alliance_status" : { get_alliance_status() }
    }
```

We add an `alliance_status` block if this empire is in an alliance. It contains the same information as `get_alliance_status`

## create_alliance ( session_id, building_id, name )

Create a new alliance. Returns the same output as `get_alliance_status`.

### session_id

A session id.

### building_id

The unique id of the embassy.

### name

A unique name for this alliance. Must be between 3 and 30 characters, cannot contain profanity or restricted characters.

## dissolve_alliance ( session_id, building_id )

Can only be called by alliance leader. Disbands an existing alliance.

NOTE: All space stations associated with the alliance will be abandoned and converted to asteroids.

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

The unique id of the embassy.

## get_alliance_status ( session_id, building_id )

Returns everything about an alliance that members should know.

```json
{
  "status": {
    /* ... */
  },
  "alliance": {
    "id": "id-goes-here",
    "name": "United Federation of Planets",
    "members": [
      {
        "empire_id": "id goes here",
        "name": "Klingons"
      }
      /* ... */
    ],
    "leader_id": "id goes here",
    "forum_uri": "http://forum.example.com/",
    "description": "This is public information.",
    "announcements": "This is private information.",
    "date_created": "01 31 2010 13:09:05 +0600"
  }
}
```

### session_id

A session id.

### building_id

The unique id of the embassy.

## send_invite ( session_id, building_id, invitee_id, [ message ] )

Can only be called by alliance leader. Invite an empire to an alliance.

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

The unique id of the embassy.

### invitee_id

The unique id of an empire you'd like to invite to an alliance. See ["search_empires" in Empire](/api/Empire#search_empires) to look up empire ids.

### message

Optional. A personalized welcome message that will be included in the invitation.

## withdraw_invite ( session_id, building_id, invite_id, [ message ] )

Can only be called by alliance leader. Delete an invitation.

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

The unique id of the embassy.

### invite_id

The unique id of an invitation. See `get_pending_invites` for details.

### message

Optional. A personalized message that will be sent to the user about why their invitation has been withdrawn.

## accept_invite ( session_id, building_id, invite_id, [ message ] )

Accept an invitation. Returns the same output as `get_alliance_status`.

### session_id

A session id.

### building_id

The unique id of the embassy.

### invite_id

The unique id of an invitation. See `get_my_invites` for details.

### message

Optional. A personalized message that will be sent to the alliance leader with your acceptance.

## reject_invite ( session_id, building_id, invite_id, [ message ] )

Delete an invitation.

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

The unique id of the embassy.

### invite_id

The unique id of an invitation. See `get_my_invites` for details.

### message

Optional. A personalized message that will be sent to the alliance leader along with your rejection.

## get_pending_invites ( session_id, building_id )

Can only be called by the alliance leader. Returns a list of invitations that have been sent out, but that have not been accepted, rejected, or withdrawn.

```json
{
  "status": {
    /* ... */
  },
  "invites": [
    {
      "id": "id-goes-here",
      "name": "The Borg",
      "empire_id": "id-goes-here"
    }
    /* ... */
  ]
}
```

### session_id

A session id.

### building_id

The unique id of the embassy.

## get_my_invites ( session_id, building_id )

Returns a list of invitations that have been offered to this empire.

```json
{
  "status": {
    /* ... */
  },
  "invites": [
    {
      "id": "id-goes-here",
      "name": "United Federation of Planets",
      "alliance_id": "id-goes-here"
    }
    /* ... */
  ]
}
```

### session_id

A session id.

### building_id

The unique id of the embassy.

## assign_alliance_leader ( session_id, building_id, new_leader_id )

Sets a new empire to lead the alliance. Can only be called by the current alliance leader. Returns the same thing as `get_alliance_status`.

### session_id

A session id.

### building_id

The unique id of the embassy.

### new_leader_id

The unique id of an empire that will lead the alliance going forward. The empire must already be a member of the alliance.

## update_alliance ( session_id, building_id, params )

Updates the properties of an alliance. Returns the same thing as `get_alliance_status`. Can only be called by the alliance leader.

### session_id

A session id.

### building_id

The unique id of the embassy.

### params

A hash reference of alliance properties. None of which can contain profanity or restricted characters. You can update any or all of these properties at the same time.

- forum_uri

  The URI to a forum where alliance discussion occurs.

- description

  Information that is publcily available about an alliance.

- announcements

  Information that is only available to alliance members.

## leave_alliance ( session_id, building_id, [ message ] )

A member of an alliance revokes their own membership.

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

The unique id of the embassy.

### message

An optional message about why you're leaving the alliance. Cannot contain restricted characters or profanity.

## expel_member ( session_id, building_id, empire_id, [ message ] )

Forcibly removes a member from an alliance. Returns the same thing as `get_alliance_status`. Can only be called by the alliance leader.

### session_id

A session id.

### building_id

The unique id of the embassy.

### empire_id

The unique id of the empire to remove from the alliance.

### message

An optional message about why you're removing them from the alliance. Cannot contain restricted characters or profanity.

## view_stash ( session_id, building_id )

Returns a list of what is in the current stash:

```json
{
  "status": {
    /* ... */
  },
  "stash": {
    // what is stored in the stash
    "gold": 4500,
    "water": 1000,
    "apple": 8
  },
  "stored": {
    // what is stored in planetary storage
    "energy": 40000,
    "algae": 43000,
    "water": 19000,
    "bauxite": 1110,
    "galena": 33120
  },
  "max_exchange_size": 30000,
  "exchanges_remaining_today": 1
}
```

### session_id

A session id.

### building_id

The unique id of the embassy.

## donate_to_stash ( session_id, building_id, donation )

Returns `view_stash`

### session_id

A session id.

### building_id

The unique id of the embassy.

### donation

A hash reference containing name value pairs of the resources you want to put into the stash from your planet.

**NOTE:** Cannot donate waste.

```json
{
  "water": 4500,
  "bread": 5000
}
```

## exchange_with_stash ( session_id, building_id, donation, request )

Returns `view_stash`

### session_id

A session id.

### building_id

The unique id of the embassy.

### donation

A hash reference containing name value pairs of the resources you want to put into the stash from your planet.

**NOTE:** Cannot donate waste.

```json
{
  "water": 4500,
  "bread": 5000
}
```

### request

A hash reference containing name value pairs of the resources you want to pull from the stash stash onto your planet.

**NOTE:** The total sum, must add up to the sum of the donation, but can be in different concentrations.

```json
{
  "energy": 2000,
  "meal": 7500
}
```

## view_propositions (session_id, building_id )

Returns a list of the pending propositions.

```json
    {
       "status" : { /* ... */ },
       "propositions" : [
           {
              "id" : "id-goes-here",
              "name" : "Rename Station",
              "description" : "Rename the station from 'Bri Prui 7' to 'Deep Space 1'.",
              "votes_needed" : 7,
              "votes_yes" : 1,
              "votes_no" : 0,
              "status" : "Pending",
              "date_ends" : "01 31 2010 13:09:05 +0600",
              "proposed_by" : {
                   "id" : "id-goes-here",
                   "name" : "Klingons",
              },
              "my_vote" : 0 # not present if they haven't voted
           },
           /* ... */
       ]
    }
```

### session_id

A session id.

### building_id

The unique id of the embassy.

## cast_vote ( session_id, building_id, proposition_id, vote )

Casts a vote for or against a proposition.

```json
    {
       "status" : { /* ... */ },
       "proposition" : {
           "id" : "id-goes-here",
           "name" : "Rename Station",
           "description" : "Rename the station from 'Bri Prui 7' to 'Deep Space 1'.",
           "votes_needed" : 7,
           "votes_yes" : 2,
           "votes_no" : 0,
           "status" : "Pending",
           "date_ends" : "01 31 2010 13:09:05 +0600",
           "proposed_by" : {
                "id" : "id-goes-here",
                "name" : "Klingons",
           },
           "my_vote" : 0 # not present if they haven't voted
       }
    }
```

### session_id

A session id.

### building_id

The unique id of the parliament.

### proposition_id

The id of the propostion you're casting this vote for or against. See `view_propositions` for a list.

### vote

A boolean indicating which way you wish to vote. 1 for yes. 0 for no. Default is 0.

```

```
