#!/bin/bash
ps aux
echo "Enter the PID to kill:"
read PID
kill -9 $PID
