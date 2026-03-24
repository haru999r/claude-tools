PREFIX ?= $(HOME)/.local
CONFIG_DIR ?= $(HOME)/.config/tab

.PHONY: install uninstall

install:
	@mkdir -p $(PREFIX)/bin
	@cp tab.sh $(PREFIX)/bin/tab
	@chmod +x $(PREFIX)/bin/tab
	@echo "Installed tab to $(PREFIX)/bin/tab"
	@if [ ! -f $(CONFIG_DIR)/projects.json ]; then \
		mkdir -p $(CONFIG_DIR); \
		cp config.example.json $(CONFIG_DIR)/projects.json; \
		echo "Created config at $(CONFIG_DIR)/projects.json"; \
	else \
		echo "Config already exists at $(CONFIG_DIR)/projects.json (skipped)"; \
	fi

uninstall:
	@rm -f $(PREFIX)/bin/tab
	@echo "Removed $(PREFIX)/bin/tab"
	@echo "Config at $(CONFIG_DIR)/projects.json was left intact."
