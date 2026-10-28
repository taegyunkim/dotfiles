# Keep login-shell startup minimal. zsh reads this before ~/.zshrc for login
# shells, and all interactive setup now lives in ~/.zshrc.

# dogbrew shell-hooks: if you don't want this to be called, comment it out and dogbrew will honour that on subsequent updates.  See also the more dangerous `dogbrew self setup --disable-shell-hooks`.
[ -f "/opt/dogbrew/share/etc/dogbrew/init.zsh" ] && . "/opt/dogbrew/share/etc/dogbrew/init.zsh"
