# buddybuild documentation

This repo contains the current buddybuild documentation source and
toolchain for producing the HTML available at
https://docs.buddybuild.com/.

Note: buddybuild's REST API documentation exists in a separate repo:
https://github.com/buddybuild-public/apidocs.buddybuild.com

## Copyright

This repo and its contents are copyright &copy; 2017 by buddybuild,
under the Creative Common Attribution-NonCommerical-NoDerivatives 4.0
International license ([CC BY-NC-ND
4.0](https://creativecommons.org/licenses/by-nc-nd/4.0/)).


## Purpose

Buddybuild makes this repo available for a couple of reasons:

* GitHub issues make it easy to request specific fixes to the
  documentation.

* Anyone can contribute to the documentation via GitHib pull requests.
  We hope that the buddybuild community is willing to share their
  knowledge and experience by helping us to improve the documentation.

  Note: We review all pull requests, but we cannot promise to approve all
  submissions.


## Authors

The buddybuild team.


## Building

There are several requirements for building the documentation:

* A Linux or Mac environment
* A current version of [Yarn](https://yarnpkg.com/en/docs/install)
* A current version of [GitBook](https://github.com/GitbookIO/gitbook)
* Version 1.5.5 (or higher) of 
  [Asciidoctor](https://rubygems.org/gems/asciidoctor)

There are a few optional requirements:

* [hunspell](http://hunspell.github.io/) (to run `make spell`)
* [HTML-Proofer](https://github.com/gjtorikian/html-proofer) (to run `make proof`)

To build the documentation:

```bash
make
```
