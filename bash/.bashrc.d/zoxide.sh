# Set up smarter directory navigation with zoxide.
if command -v zoxide >/dev/null 2>&1; then
    eval "$(zoxide init bash)"
    alias cd='z'
    alias cdi='zi'
fi
