These scripts are used to help with monitoring several runs on a cluster.

## Monitoring .dat files

* `domain-info.sh`: Uses [SpEC](https://www.black-holes.org/SpEC.html) tool `DomainInfo` to get number of points and subdomains over time

* `keep-last-checkpoint.sh`: Cleans checkpoint directories every 4 hours, but keeps the last for each segment.  I run this in a crontab.

* `latest-times.sh`: Prints a quick overview table of the simulations

* `rejoin-segments.sh`: Iterates over all simulations to do `CombineSegments.py`, so all `*.dat`'s are are joined together

## Automating some parts of the process to visualize matter on the grid

* `per-segment-volume-generator.sh`: For a specified segment from a specified run, run `ConvertToVtk` to output data in paraview format.

* `volume-generater.sh`: Loops through all simulations and dumps latest data for paraviewing.

* `match-domain-time-to-pv-file.py`: simple python script to do the arithmetic that bash cannot do.  (Got all the way through the bash script before realizing this.  Would recommend going back and doing this in python instead.)
