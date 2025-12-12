# Advent of Code Day Template

A lightweight PHP template for solving Advent of Code problems.

## Quick Start

1. **Copy this template folder** into your day folder (e.g., `day01/`, `day02/`, etc.)

2. **Install dependencies:**

   ```bash
   composer install
   ```

3. **Run your solution:**

   ```bash
   composer run input.txt
   ```

   Or directly: `php bin/run.php input.txt`

4. **Run tests:**

   ```bash
   composer test
   ```

   Or directly: `php bin/test.php`

## Files

**Main files (edit these!):**

- `Solution.php` - Your solution class
- `SolutionTest.php` - Your tests
- `input.txt` - Your puzzle input (replace with actual input)

**Configuration:**

- `composer.json` - PHP dependencies configuration

**Infrastructure (in `bin/` folder - rarely need to edit):**

- `bin/run.php` - Script to run your solution
- `bin/test.php` - Script to run tests
- `bin/phpunit.xml` - PHPUnit test configuration
- `bin/Utility.php` - Helper utilities (optional, edit as needed)

## Requirements

- PHP 8.5 or newer
- Composer

## Usage

### Running Solutions

Using Composer (recommended):

```bash
composer run input.txt
```

Or directly:

```bash
php bin/run.php input.txt
```

### Running Tests

Using Composer (recommended):

```bash
composer test
```

Or directly:

```bash
php bin/test.php
```

Or with PHPUnit directly:

```bash
vendor/bin/phpunit
```
