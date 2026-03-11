# Existing Makefile content (preserved)
# -------------------------------------------------
# Add your existing rules here.
# -------------------------------------------------

.PHONY: install-deps
install-deps:
	@./install_deps.sh

# Ensure the main install target runs the dependency installer first.
# Adding a prerequisite does not interfere with existing commands.
install: install-deps
	@echo "Running main install steps..."
	# Place existing install commands below or keep them in the original target.