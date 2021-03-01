#!/bin/sh

readonly port=8000

xdg-open http://localhost:${port}
python -m http.server ${port}
