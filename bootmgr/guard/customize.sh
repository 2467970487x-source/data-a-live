# Magisk installer: the guard runs pinfile from the module folder.
# KernelSU has no set_perm(), so fall back to plain chmod/chown there.
if command -v set_perm >/dev/null 2>&1; then
	set_perm "$MODPATH/pinfile" 0 0 0755
else
	chmod 0755 "$MODPATH/pinfile" 2>/dev/null || chmod 755 "$MODPATH/pinfile"
	chown 0:0 "$MODPATH/pinfile" 2>/dev/null || true
	ui_print "- KernelSU: pinfile set to 0755 root:root"
fi
