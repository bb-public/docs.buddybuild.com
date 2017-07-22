book_targets := $(wildcard \
	book.json \
	README.adoc \
	SUMMARY.adoc \
	*/*.adoc \
	*/*.gif \
	*/*.png \
	*/*.jpg \
	_css/* \
	_img/* \
	_js/* \
	_layouts/website/* \
)

YARN := $(shell command -v yarn 2> /dev/null)
GITBOOK := $(shell command -v gitbook 2> /dev/null)
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
	@echo "Checking for gitbook..."
ifndef GITBOOK
	$(error "gitbook required for building this documentation.")
endif
	gitbook install

# Asciidoctor setup
setup_asciidoctor:
	@echo "Checking for asciidoctor..."
ifndef ASCIIDOCTOR
	echo "Asciidoctor is required to build this documentation. Installing..."
	bundle install
endif
# Build the main artifacts.
book: _book tidy

_book: $(book_targets)
	gitbook build

# Remove all built artifacts.
clean:
	rm -rf _book

# Remove artifacts that shouldn't be published.
tidy:
	rm -rf _book/_dicts _book/Gemfile _book/Gemfile.lock _book/Makefile _book/package.json _book/yarn.lock _book/npm-debug.log _book/rewrites.csv

# 'test' the artifacts
test: spell proof

# Spell check the source files.
spell:
	@command -v hunspell >/dev/null 2>&1 || { echo >&2 "hunspell required for spell testing."; exit 1; }
	find . -name "*.adoc" -exec hunspell -d _dicts/buddybuild,_dicts/en_US -l '{}' \; | sort -u

# Run htmlproofer on the artifacts to catch bad images, links, etc.
proof: clean _book tidy
	@command -v htmlproofer >/dev/null 2>&1 || { echo >&2 "htmlproofer required for link testing."; exit 1; }
	htmlproofer _book

css:
	cp _css/* _book/_css/

js:
	rm -rf _book/_js
	cp -a _js _book/

# Build the main artifacts with debugging output enabled.
debug: _debug tidy

_debug: $(book_targets)
	gitbook build --log=debug --debug
