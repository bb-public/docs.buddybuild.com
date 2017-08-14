YARN := $(shell command -v yarn 2> /dev/null)
ASCIIDOCTOR := $(shell command -v asciidoctor 2> /dev/null)

# The default target.
all: setup book

# Declare our phony targets.
.PHONY: book clean test spell proof css js tidy debug _debug setup \
	setup_yarn setup_gitbook setup_asciidoctor setup_javascript

# Install everything needed to start authoring in GitBook
setup: setup_yarn setup_gitbook setup_asciidoctor

# Yarn setup
setup_yarn:
	@echo "Checking for yarn..."
ifndef YARN
	$(error "yarn is required for managing node dependencies.")
endif
	yarn

# GitBook setup
setup_gitbook:
	./node_modules/.bin/gitbook install

# Asciidoctor setup
setup_asciidoctor:
	@echo "Checking for asciidoctor..."
ifndef ASCIIDOCTOR
	echo "Asciidoctor is required to build this documentation. Installing..."
	bundle install
endif
# Build the main artifacts.
book: clean _book tidy

_book:
	./node_modules/.bin/gitbook build

# Remove all built artifacts.
clean:
	rm -rf _book

# Remove artifacts that shouldn't be published.
tidy:
	rm -rf _book/CNAME _book/Gemfile _book/Gemfile.lock _book/Makefile _book/_dicts _book/deploy.py _book/npm-debug.log _book/package.json _book/package-lock.json _book/rewrites.csv _book/yarn.lock

# 'test' the artifacts
test: spell proof

# Spell check the source files.
spell:
	@command -v hunspell >/dev/null 2>&1 || { echo >&2 "hunspell required for spell testing."; exit 1; }
	@_tools/spellcheck.pl -d . -D _dicts

# Run htmlproofer on the artifacts to catch bad images, links, etc.
proof: all
	@command -v htmlproofer >/dev/null 2>&1 || { echo >&2 "htmlproofer required for link testing."; exit 1; }
	htmlproofer --url-ignore="#" --disable-external _book

# Run htmlproofer, with external checks
proofx: all
	@command -v htmlproofer >/dev/null 2>&1 || { echo >&2 "htmlproofer required for link testing."; exit 1; }
	htmlproofer --url-ignore="#" _book

css:
	cp _css/* _book/_css/

js:
	rm -rf _book/_js
	cp -a _js _book/

# Build the main artifacts with debugging output enabled.
debug: clean _debug tidy

_debug:
	./node_modules/.bin/gitbook build --log=debug --debug
