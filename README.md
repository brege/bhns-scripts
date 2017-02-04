These scripts are used to help with monitoring several runs on a cluster.

## Before you begin

1. `git clone git://github.com/brege/bhns-scripts.git`

2. `cp sample.conf paths.conf`

3. Edit `paths.conf` to provide simulation paths

## Monitoring .dat files

* `domain-info.sh`: Uses [SpEC](https://www.black-holes.org/SpEC.html) tool `DomainInfo` to get number of points and subdomains over time

* `gr-domain-info.sh`: Same as above, just on the GR side

* `keep-last-checkpoint.sh`: Ran in four hour crontab, this cleans checkpoint directories but keeps the last one for each segment

* `latest-times.sh`: Prints a quick overview table of the simulations

* `rejoin-segments.sh`: Iterates over all simulations to do `CombineSegments.py`, so all `*.dat`'s are are joined together

## Automating some parts of the process to visualize matter on the grid

* `per-segment-volume-generator.sh`: For a specified segment from a specified run, run `ConvertToVtk` to output data in paraview format

* `volume-generater.sh`: Loops through all simulations and dumps latest data for paraviewing

* `match-domain-time-to-pv-file.py`: simple python script to do the arithmetic that bash cannot do.  (Got all the way through the bash script before realizing this.  Would recommend going back and doing this in python instead.)
