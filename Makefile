build:
	echo None

install:
	mkdir -pv $(DESTDIR)/etc/profile.d/
	mkdir -pv $(DESTDIR)/etc/apt/trusted.gpg.d/
	mkdir -pv $(DESTDIR)/etc/apt/sources.list.d/
	mkdir -pv $(DESTDIR)/etc/xdg/autostart
	mkdir -pv $(DESTDIR)/usr/bin
	mkdir -pv $(DESTDIR)/usr/lib/systemd/system/
	mkdir -pv $(DESTDIR)/usr/share/polkit-1/rules.d/
	cp -rv deepin-file-manager-mount.rules $(DESTDIR)/usr/share/polkit-1/rules.d/dde-file-manager-mount.rules
	cp -rv dde.sh $(DESTDIR)/etc/profile.d/dde.sh
	#cp -rv debian-dde.list $(DESTDIR)/etc/apt/sources.list.d/debian-dde.list
	cp -rv debiandde-first-config.service $(DESTDIR)/usr/lib/systemd/system/debiandde-first-config.service
	cp -rv debian-dde.gpg $(DESTDIR)/etc/apt/trusted.gpg.d/debian-dde.gpg
	cp debiandde-config-after-desktop $(DESTDIR)/usr/bin/debiandde-config-after-desktop
	cp debiandde-config-after-desktop.desktop $(DESTDIR)/etc/xdg/autostart/debiandde-config-after-desktop.desktop
	chmod +x $(DESTDIR)/etc/profile.d/dde.sh
	chmod +x $(DESTDIR)/usr/bin/debiandde-config-after-desktop
