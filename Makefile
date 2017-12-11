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
	cd ./node_modules/gitbook-plugin-theme-buddybuild && npm install
	cd ./node_modules/gitbook-plugin-lunr && npm install
	cd ./node_modules/gitbook-plugin-search && npm install

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
	rm -rf _book/CNAME _book/Gemfile _book/Gemfile.lock _book/Makefile _book/_common _book/_dicts _book/deploy.py _book/npm-debug.log _book/package.json _book/package-lock.json _book/rewrites.csv _book/yarn.lock

# 'test' the artifacts
test: setup spell alt imgsize length repeats proof unusedimg missed

# Spell check the source files.
spell:
	@command -v hunspell >/dev/null 2>&1 || { echo >&2 "hunspell required for spell testing."; exit 1; }
	@command -v node_modules/gitbook-plugin-buddybuild/scripts/spellcheck.pl >/dev/null 2>&1 || { echo >&2 "run make setup before spell testing."; exit 1; }
	@node_modules/gitbook-plugin-buddybuild/scripts/spellcheck.pl -d . -D node_modules/gitbook-plugin-buddybuild/dictionaries

# Check for line length violations
length:
	@node_modules/gitbook-plugin-buddybuild/scripts/linelength.pl -d . -l 80

# Check for repeated words
repeats:
	@node_modules/gitbook-plugin-buddybuild/scripts/repeated_words.pl -d .

# Check for incorrect image sizes
imgsize:
	@node_modules/gitbook-plugin-buddybuild/scripts/imgsize.pl -v -d .

# Check for any unused images
unusedimg:
	@node_modules/gitbook-plugin-buddybuild/scripts/unused_images.pl -d .

# Check for unspecified image alt tags
alt:
	@node_modules/gitbook-plugin-buddybuild/scripts/unassigned_alt.pl -d .

# Run htmlproofer on the artifacts to catch bad images, links, etc.
proof: all
	@command -v htmlproofer >/dev/null 2>&1 || { echo >&2 "htmlproofer required for link testing."; exit 1; }
	htmlproofer --allow-hash-href  --disable-external _book

# Run htmlproofer, with external checks
proofx: all
	@command -v htmlproofer >/dev/null 2>&1 || { echo >&2 "htmlproofer required for link testing."; exit 1; }
	htmlproofer --allow-hash-href  _book

# Run htmlproofer, assuming build already performed
proofq:
	@command -v htmlproofer >/dev/null 2>&1 || { echo >&2 "htmlproofer required for link testing."; exit 1; }
	htmlproofer --allow-hash-href  _book

# Check for unconverted topics in output folder; means they're missing
# from the TOC.
missed: _book
	@echo "Checking for topics missing from the TOC..."
	@find _book -name '*.adoc' | grep . && exit 1 || exit 0;

css:
	cp _css/* _book/_css/

js:
	rm -rf _book/_js
	cp -a _js _book/

# Build the main artifacts with debugging output enabled.
debug: clean _debug tidy

_debug:
	./node_modules/.bin/gitbook build --log=debug --debug
