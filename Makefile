PREFIX ?= $(HOME)/.local
CONFIG_DIR ?= $(HOME)/.config/tab

.PHONY: install install-tab install-disablesleep uninstall

install: install-tab install-disablesleep

install-tab:
	@mkdir -p $(PREFIX)/bin
	@cp tab/tab.sh $(PREFIX)/bin/tab
	@chmod +x $(PREFIX)/bin/tab
	@echo "Installed tab to $(PREFIX)/bin/tab"
	@if [ ! -f $(CONFIG_DIR)/projects.json ]; then \
		mkdir -p $(CONFIG_DIR); \
		cp tab/config.example.json $(CONFIG_DIR)/projects.json; \
		echo "Created config at $(CONFIG_DIR)/projects.json"; \
	else \
		echo "Config already exists at $(CONFIG_DIR)/projects.json (skipped)"; \
	fi

install-disablesleep:
	@mkdir -p $(PREFIX)/bin
	@cp disablesleep/disablesleep.sh $(PREFIX)/bin/disablesleep
	@chmod +x $(PREFIX)/bin/disablesleep
	@echo "Installed disablesleep to $(PREFIX)/bin/disablesleep"

uninstall:
	@rm -f $(PREFIX)/bin/tab
	@rm -f $(PREFIX)/bin/disablesleep
	@echo "Removed $(PREFIX)/bin/tab and $(PREFIX)/bin/disablesleep"
	@echo "Config at $(CONFIG_DIR)/projects.json was left intact."
