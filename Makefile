PREFIX	:= /usr

define setup
	install -m 755 enversh.sh $(PREFIX)/bin/enversh
endef

define remove
	rm -rf $(PREFIX)/bin/enversh
endef

install:
	@$(setup)
	@echo "installed."

uninstall:
	@$(remove)
	@echo "uninstalled."

reinstall:
	@$(remove)
	@$(setup)
	@echo "reinstalled."

.PHONY: install, uninstall, reinstall