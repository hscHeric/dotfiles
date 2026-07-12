# Start Emacs with dark GTK decorations without changing the global theme.
emacs() {
    GTK_THEME=Adwaita:dark command emacs "$@"
}
