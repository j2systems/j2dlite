#!/bin/bash

kill -9 $(pgrep -o shellinaboxd)
shellinaboxd -t --port 4202 -s ":root::/tmp:/bin/sh" &

