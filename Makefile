# This Makefile target is for installing and enabling the ClamAV hourly user timer

security:
	stow systemd-user
	systemctl --user daemon-reload
	systemctl --user enable --now clamav-hourly.timer
