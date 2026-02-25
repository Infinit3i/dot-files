# ClamAV Hourly Timer (User)

After running:

    stow systemd-user

Enable the timer:

    systemctl --user daemon-reload
    systemctl --user enable --now clamav-hourly.timer

Check status:

    systemctl --user list-timers
