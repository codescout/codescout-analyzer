# codescout-analyzer

Generate code analysis report using Flog, Flay, Brakeman and Rubocop

## Overview

Codescout analyzer is an open-source library designed to produce a static code analysis report
for metrics like complexity, duplication, security and code guidelines. It heavily relies on popular projects:

- [Flog](https://github.com/seattlerb/flog) - code complexity
- [Flay](https://github.com/seattlerb/flay) - code duplication
- [Brakeman](https://github.com/presidentbeef/brakeman) - rails security
- [Rubocop](https://github.com/bbatsov/rubocop) - code formatting and styleguide
- [Churn](https://github.com/danmayer/churn) - code changes frequency

## Installation

You can install library using Rubygems:

```
gem install codescout-analyzer
```

Or include it into Gemfile:

```
gem "codescout-analyzer"
```

## Usage

To generante code metrics report simple run the following command:

```
codescout /path/to/your/project
```

## Testing

TODO

## License

The MIT License (MIT)

Copyright (c) 2014 Doejo LLC, <dan@doejo.com>