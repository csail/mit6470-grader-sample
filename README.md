# MIT 6.470 sample grading endpoint

This repository contains all the infrastructure needed to grade CSS and
JavaScript problems, together with sample code for a few problems. The actual
problems used in 6.470 hackathons are not provided.


## Pre-requisites

The grading endpoint is built on [Ruby 1.9.3](http://www.ruby-lang.org/) and
uses the [Bundler gem](http://gembundler.com/) to manage its dependencies.
The endpoint uses [Xvfb](http://en.wikipedia.org/wiki/Xvfb) to run the
[Chromium](http://www.chromium.org/) browser in server environments
that do not have X servers. The grading endpoint also needs Chromium, or
Google's slightly customized build,
[Google Chrome](https://www.google.com/chrome/).

This code is tested on the following platforms.

* Ubuntu 12.10
* Fedora 18
* Max OSX 10.8

The sections below contain setup instructions for each supported platform.

### Ubuntu 12.10

Get Ruby, Bundler, and Xvfb.

```bash
sudo apt-get install ruby-full xvfb
sudo gem install bundler
```

Get Google Chrome.

```bash
wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | sudo apt-key add -
sudo sh -c "echo \"deb https://dl.google.com/linux/deb/ stable main\" > /etc/apt/sources.list.d/google.list"
sudo apt-get -qq update && sudo apt-get -qq install google-chrome-stable
```

### Fedora 17+

Get Ruby, Bundler, and Xvfb.

```bash
sudo yum install ruby xorg-x11-server-Xvfb
sudo gem install bundler
```

Get Google Chrome.

```bash
wget -q https://dl-ssl.google.com/linux/linux_signing_key.pub
sudo rpm --import linux_signing_key.pub
rm linux_signing_key.pub
sudo sh -c "echo \"[google-chrome]\" > /etc/yum.repos.d/google-chrome.repo"
sudo sh -c "echo \"name=google-chrome\" >> /etc/yum.repos.d/google-chrome.repo"
sudo sh -c "echo \"baseurl=https://dl.google.com/linux/chrome/rpm/stable/\\\$basearch\" >> /etc/yum.repos.d/google-chrome.repo"
sudo sh -c "echo \"enabled=1\" >> /etc/yum.repos.d/google-chrome.repo"
sudo sh -c "echo \"gpgcheck=1\" >> /etc/yum.repos.d/google-chrome.repo"
sudo yum install google-chrome-stable
```

### Mac OSX 10.7+

Install the [Homebrew package manager](http://mxcl.github.com/homebrew/).

```bash
ruby -e "$(curl -fsSkL raw.github.com/mxcl/homebrew/go)"
# Follow the instructions to get Homebrew installed
```

Get Ruby and Bundler.

```bash
brew install ruby
gem install bundler
```

Install Google Chrome from
[the official download site](https://google.com/chrome).

NOTE: OSX 10.7 and 10.8 come with Ruby 1.8.7, which is very old and not
supported by this codebase. You do not need to use Homebrew to get Ruby 1.9.3,
if you're willing to
[do some research](https://www.google.com/search?q=osx+ruby+1.9.3).


## Setup

Get the code and the libraries.

```bash
git clone http://git.pwnb.us/csail/mit6470-grader-sample.git
cd mit6470-grader-sample
bundle install
```

Start a development instance at
[http://localhost:9000/](http://localhost:9000/).

```bash
bundle exec foreman start
```

### Production Deployment

First off, it's probably a good idea to start the production instance on your
development machine and do a smoke test.

```bash
bundle exec foreman start --port 9500 --procfile Procfile.prod
```

The production setup is very similar to the development setup, except that you
should set up the grading endpoint as a system daemon, instead of starting it
manually.

```bash
sudo foreman export upstart /etc/init --procfile Procfile.prod --user $USER --port 12300
```


## Problem Development.

Read the code behind the sample problems in the
[the problem directory](https://github.com/csail/mit6470-grader-sample/tree/master/problems).

The
[docs for webkit_remote](http://rdoc.info/github/pwnall/webkit_remote/) and
[docs for webkit_remote_unstable](http://rdoc.info/github/pwnall/webkit_remote_unstable/)
can help understand and write problem code.


## Copyright

Copyright (c) 2012 Victor Costan. See LICENSE.txt for further details.
