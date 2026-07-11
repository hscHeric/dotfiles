# Use fd for interactive file searches.
if command -v fd >/dev/null 2>&1; then
    alias find='fd'
    alias f='fd'
fi
