# Keep login-shell startup minimal. zsh reads this before ~/.zshrc for login
# shells, and all interactive setup now lives in ~/.zshrc.

path=(/opt/dogbrew/shims/bin /opt/dogbrew/bin ${${path:#/opt/dogbrew/shims/bin}:#/opt/dogbrew/bin}); fpath=(/opt/dogbrew/share/zsh/site-functions ${fpath:#/opt/dogbrew/share/zsh/site-functions}); case ":${MANPATH-}:" in *:'/opt/dogbrew/share/man':*) ;; *) export MANPATH='/opt/dogbrew/share/man':${MANPATH-} ;; esac # dogbrew shell setup
