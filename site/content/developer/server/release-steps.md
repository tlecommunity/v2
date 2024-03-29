---
date: 2022-10-31
type: 'page'
---

This is a basic rundown of the steps used for a release.

Using the release # of 3.0552
 1. Make sure master matches last release. (should already be set)
 2. cd Lacuna-Server-Open
 3. git checkout develop
 4. git pull --ff-only pb-ls-open develop
 5. git checkout -b rel-3.0552 (release number in Lacuna.pm)
 6. git push pb-ls-open rel-3.0552
 7. cd ../Lacuna-Server-Open
 8. Same routine with master
 9. git checkout develop
10. git pull --ff-only pb-ls develop
11. git pull --ff-only pb-ls-open develop (This shouldn't pull over anything new)
12. git push pb-ls develop
13. git checkout pt
14. git pull --ff-only pb-ls-open pt
15. git merge develop (Again, shouldn't be anything new, if not we shouldn't do a release on non-tested items)
16. git push pb-ls pt
17. git checkout develop
18. git checkout -b rel-3.0552
19. git push pb-ls rel-3.0552
20. git checkout us1
21. git pull --ff-only pb-ls us1
22. git push pb-ls us1 (should say up to date)
23. git merge rel-3.0552
24. ssh to us1.lacunaexpanse.com, us1-db1, us1-util1, us1-web1, us1-web2
25. scp var/upgrades/3.0552.sql to us1-db1 and run it.
26. On other four, go to /data/Lacuna-Server-Open as root.  (sudo su - should put you in /data/Lacuna-Server-Open/bin)
27. Run close to simultanous git pull origin us1
    There should be no merge conflicts.
28. On us1-web1 and us1-web2 cd into bin and run ./restart_starman.sh (must be done at same time)
29. On the News Forum you should post a release summary and make an announcement using the admin screen.
