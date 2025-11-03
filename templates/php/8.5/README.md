# 🎄 Advent of Code PHP Template

This is a template for solving Advent of Code problems with PHP 8.5

---

## ⚙️ Prerequisites

To run this project, you will need the following installed on your system:

1. **PHP 8.5** (or newer)
2. **Composer** (PHP dependency manager)

---

## 💻 Installation

### 1. PHP 8.5 Installation

Since PHP 8.5 is a development/unreleased version, the instructions for installation vary by operating system. The steps below are based on an [article][install-php-8.5] by Benjamin Crozat, primarily for macOS using Homebrew.

#### **macOS (using Homebrew)**

If you use Homebrew, you can install the latest development version of PHP 8.5 using a dedicated tap:

1. **Update Homebrew:**

    ```bash
    brew update
    ```

2. **Add the PHP Tap:**

    ```bash
    brew tap shivammathur/php
    ```

3. **Install PHP 8.5:**

    ```bash
    brew install shivammathur/php/php@8.5
    ```

4. **Link PHP 8.5** (to make it the active `php` command):

    ```bash
    brew link --overwrite --force shivammathur/php/php@8.5
    ```

> *Tip: If you have multiple PHP versions, run `brew unlink php` (or `brew unlink php@<version>`) before linking 8.5.*

### 2. Composer Installation

[Composer][install-composer] is a dependency manager for PHP. Follow these steps for a **global installation**:

1. **Download the Installer:**

    ```bash
    php -r "copy('[https://getcomposer.org/installer](https://getcomposer.org/installer)', 'composer-setup.php');"
    ```

2. **Run the Installer** (to install it globally in `/usr/local/bin`):

    ```bash
    php composer-setup.php --install-dir=/usr/local/bin --filename=composer
    ```

3. **Clean up the installer file:**

    ```bash
    php -r "unlink('composer-setup.php');"
    ```

4. **Verify the installation:**

    ```bash
    composer --version
    ```

---

## ▶️ How to Run the Solutions

1. **Clone the repository:**

    ```bash
    git clone [your-repo-url]
    cd [your-repo-name]
    ```

2. **Install Project Dependencies** (if any are defined in `composer.json`):

    ```bash
    composer install
    ```

3. **Execute a specific day's solution:**
    Run a solution directly from the terminal:

    ```bash
    php bin/run.php day01 input.txt
    ```

4. **Execute a test file for the current day's solution:**
    Run a solution directly from the terminal:

    ```bash
    php bin/test.php day01
    ```

[install-php-8.5]: <https://benjamincrozat.com/php-85>
[install-composer]: <https://getcomposer.org/>
