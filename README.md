# castor

Very simple command line web crawler with Crystal (http://crystal-lang.org/)

## Requirements

- [Crsytal](http://crystal-lang.org/) >= 0.10.0
- [Rake](https://github.com/ruby/rake) >= 10.4.0

## Installation

```bash
# clone
$ git clone git@github.com:muniere/castor.git

# install
$ cd castor
$ ./configure --prefix=/usr/local
$ rake && rake install

# or only link
$ rake && rake link
```

## Usage

### Index links in URL

```bash
# default
$ castor index http://www.example.com/

# index only links of text
$ castor index --href-text http://www.example.com/

# index only links of image
$ castor index --href-image http://www.example.com/

# index only images
$ castor index --image http://www.example.com/

# index only scripts
$ castor index --script http://www.example.com/
```

### Crawl links in URL

```bash
# default
$ castor crawl http://www.example.com/

# crawl only images
$ castor crawl --image http://www.example.com/

# crawl with gieven concurrency
$ castor crawl --concurrency=10 http://www.example.com/

# grep uris of contents
$ castor crawl --image --grep="foobar.*\.jpg" http://www.example.com/

# dry run
$ castor crawl --script --dry-run http://www.example.com/
```
