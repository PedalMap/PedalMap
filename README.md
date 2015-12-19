PedalMap
========

PedalMap repo

We want to do 3 things with beaacons: Create, update, destroy

- Create when new UUID/major/minor is seen AND beacon not in list
- Update when UUID/major/minor exists AND beaacon is in list
- Destroy when UUID/major/minor IS NOT found BUT beacon is in list

method to update: during an update, report rssi. IF rssi is very close THEN create bicycle object
 - with this, we will determine when to start ride, how far to let RSSI drift while ride is still 
going, and when to cut off the ride


Model
- for as long as ViewController exists, it maintains list of beacons
- for as long as Beacon exists, it creates and destroys individual beacons within that list
