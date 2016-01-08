# wwalk

Very simple command line web walker with Crystal (http://crystal-lang.org/)

## Requirements

- [Crsytal](http://crystal-lang.org/) >= 0.10.0
- [Rake](https://github.com/ruby/rake) >= 10.4.0

## Installation

```bash
# clone
$ git clone git@github.com:muniere/wwalk.git

# install
$ cd wwalk
$ ./configure --prefix=/usr/local
$ rake && rake install

# or only link
$ rake && rake link
```

## Usage

### Index links in URL

```bash
# default
$ wwalk index http://www.example.com/

# index only links of text
$ wwalk index --href-text http://www.example.com/

# index only links of image
$ wwalk index --href-image http://www.example.com/

# index only images
$ wwalk index --image http://www.example.com/

# index only scripts
$ wwalk index --script http://www.example.com/
```

### Crawl links in URL

```bash
# default
$ wwalk crawl http://www.example.com/

# crawl only images
$ wwalk crawl --image http://www.example.com/

# crawl with gieven concurrency
$ wwalk crawl --concurrency=10 http://www.example.com/

# grep uris of contents
$ wwalk crawl --image --grep="foobar.*\.jpg" http://www.example.com/

# dry run
$ wwalk crawl --script --dry-run http://www.example.com/
```
