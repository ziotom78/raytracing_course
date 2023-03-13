#!/bin/sh

readonly DELAY_MS=200
echo "Focus on the terminal window, you have 5 seconds:"
sleep 5s

type_line () {
    line="$1"
    delay=$2
    xdotool type --delay $DELAY_MS "$line"
    xdotool key Enter
    if [ "$delay" != "" ]; then
        sleep $delay
    fi
}

type_line 'python3 error_example2.py' 7s

type_line 'ipython' 3s
type_line '%pdb on' 3s
type_line '%run error_example2.py' 10s
type_line 'print(my_list)' 3s
type_line 'print(sorted_list)' 3s

xdotool key ctrl+d
xdotool key ctrl+d
xdotool key ctrl+d
