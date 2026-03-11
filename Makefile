.PHONY: install uninstall lint test clean

install:
	@echo "Running install.sh..."
	@./install.sh

uninstall:
	@echo "Running uninstall.sh..."
	@./uninstall.sh

lint:
	@echo "Running shellcheck on all *.sh files..."
	@shopt -s nullglob; \
	files=$$(find . -type f -name "*.sh"); \
	if [ -z "$$files" ]; then \
	  echo "No shell scripts found."; \
	else \
	  shellcheck $$files; \
	fi

test:
	@echo "Executing test suite..."
	@if [ -x "./test.sh" ]; then \
	  ./test.sh; \
	elif [ -x "./run-ci.sh" ]; then \
	  ./run-ci.sh; \
	else \
	  echo "No test script found (expected test.sh or run-ci.sh)."; \
	  exit 1; \
	fi

clean:
	@echo "Cleaning generated backup directories and temporary files..."
	@find . -type d -name "*~" -exec rm -rf {} + 2>/dev/null || true
	@find . -type d -name "*backup*" -exec rm -rf {} + 2>/dev/null || true
	@find . -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null || true
	@echo "Clean complete."