# Simple linux battery status logger bash script

Used it for storing my external and internal batteries health history
for my old T480 laptop in Fedora linux.

# How to use

## To make everyday logs

1. Launch `make log` to create log record for current day.

## To view history graph of capacity

1. Install asciigraph `sudo dnf install asciigraph` or use docker version of asciigraph
2. Launch `make capacity_graph`
