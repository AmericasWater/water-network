setwd("~/projects/water/model/waternet/utils")

## Make a network that looks like Y,
## Stations are order from top to bottom, and within each horizontal row, left to right.
## Counties are organized with borders like the letter W, ignoring the potential region on the left

stations <- data.frame(collection=rep("dummy", 5), colid=1:5, area=c(1, 1, 2, 1, 3), lat=c(1, 1, 0, 0, -1), lon=c(0, 1, 0, 1, 0), elev=c(2, 2, 1, 2, 0))

network <- data.frame(collection=stations$collection, colid=stations$colid, lat=stations$lat, lon=stations$lon, elev=stations$elev, nextpt=c(3, 3, 5, 5, NA), dist=rep(1, 5))

save(stations, network, file="../data/dummynet.RData")

draws <- data.frame(fips=c(1, 2, 3, 3, 4), source=c(1, 2, 3, 5, 4), justif=rep("contains", 5), downhill=F, exdist=0)

save(draws, file="../data/dummydraws.RData")
