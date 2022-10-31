---
date: 2022-10-31
type: 'page'
---

# Announcement

The announcement system is used to announced scheduled server maintenance, contests, etc.

**NOTE:** This API is **not** JSON-RPC based. It just returns an HTML document.

The client should call this URI to fetch the announcement whenever the `server` status block contains `announcement` like this:

```json
{
  "status": {
    "server": {
      "announcement": 1
    }
  }
}
```

http://servername.lacunaexpanse.com/announcement?session_id=xxxxxxxxxxxxxxxx

By calling this method to fetch the announcement, it will automatically remove the announcement from the
`server` block so that you know you don't have to fetch it again.

The target dialog window size should be 200x200px, but scrollable.
