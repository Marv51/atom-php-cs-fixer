# php-cs-fixer Atom-Package

Run the "[PHP Coding Standards Fixer](http://cs.sensiolabs.org)" within your Atom Editor

![A screenshot of your package](https://raw.github.com/pfefferle/atom-php-cs-fixer/master/php-cs-fixer.gif)

## Installation

```sh
$ apm install php-cs-fixer
```

or find it in the Packages tab under settings

## Requirements

The package requires the "[PHP Coding Standards Fixer](http://cs.sensiolabs.org)" Cli build by [SensioLabs](http://sensiolabs.com).

Installation via Composer

```sh
$ ./composer.phar global require fabpot/php-cs-fixer
```

For other installation methods, see <http://cs.sensiolabs.org/#installation>

## Usage

`ctrl-cmd-s` or **Php Cs Fixer: Fix** in the Command Palette.

(The commands can also be found in the settings-menu of the Package)

## Settings

### [Mac OS X + brew](https://github.com/pfefferle/atom-php-cs-fixer/issues/7#issuecomment-118163704) (by [@gammamatrix](https://github.com/gammamatrix))

To get it to work with brew, you need to `cat` the contents of the script installed with `brew install php-cs-fixer`:

#### Check to see where it installed

```sh
which php-cs-fixer

/usr/local/bin/php-cs-fixer
```

#### Cat the script

```sh
cat /usr/local/bin/php-cs-fixer

#!/bin/sh

/usr/bin/env php -d allow_url_fopen=On -d detect_unicode=Off /usr/local/Cellar/php-cs-fixer/1.8.1/libexec/php-cs-fixer.phar $*
```

#### Paste the path for php-cs-fixer.phar in *Executable Path*

*Go back to settings in Atom for php-cs-fixer.*

`/usr/local/Cellar/php-cs-fixer/1.8.1/libexec/php-cs-fixer.phar`

**FYI:** *PHP Executable Path* is empty for my set up. I also installed PHP with brew.

Use the keystroke: `ctrl-cmd-s`

I hope this helps 8)

This works for me without errors.

## FAQ

### I have updated the plugin to 2.3.0 and it does not work any more

I had to add a new settings-parameter `Php Executable Path` to get the plugin running on Windows, so be sure to check if the new setting is configured properly.
