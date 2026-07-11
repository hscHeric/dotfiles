# Use eza for interactive directory listings.
if command -v eza >/dev/null 2>&1; then
    alias ls='eza --icons=auto'
    alias ll='eza --icons=auto -lah --group-directories-first'
    alias la='eza --icons=auto -a'
    alias lt='eza --icons=auto --tree --group-directories-first'
fi
