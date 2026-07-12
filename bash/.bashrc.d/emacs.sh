# Start Emacs with a dark GTK decoration without changing the global theme.
emacs() {
    GTK_THEME=Adwaita:dark command emacs "$@"
}
