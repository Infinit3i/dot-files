# Security targets: ClamAV hourly scan and VirusTotal download watcher

security:
	stow bin
	stow systemd-user
	systemctl --user daemon-reload
	systemctl --user enable --now clamav-hourly.timer
	systemctl --user enable --now vt-watcher.service

nightlight:
	stow systemd-user
	systemctl --user daemon-reload
	systemctl --user enable --now hyprsunset-on.timer
	systemctl --user enable --now hyprsunset-off.timer
