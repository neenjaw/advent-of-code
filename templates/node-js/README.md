# 🚀 Advent of Code Template

Node.js project managed by **mise** (tool versions) and **pnpm** (packages).

## 🛠️ Setup

Follow these two steps to set up your environment:

### 1\. Install `mise`

`mise` manages the correct Node.js and pnpm versions.

* **Install `mise`:** Follow the official installation guide.
  * *Example (Linux/macOS):*

    ```bash
    curl https://mise.run | sh
    ```

* **Activate Shell Integration:** Add the activation line to your shell profile (e.g., `.zshrc`) and restart the terminal.

  ```bash
  eval "$(mise activate zsh)"
  ```

### 2\. Install Project Tools and Dependencies

Navigate to the project root and run these commands:

* **Install Tools:** `mise` installs the Node.js and pnpm versions specified in `.mise.toml`.

  ```bash
  mise install
  ```

* **Install Packages:** `pnpm` installs the project dependencies.

  ```bash
  pnpm install
  ```

-----

## ⚙️ How to Run

All operations use the `pnpm` command runner, which utilizes the correct Node.js version provided by `mise`.

### Standard Execution

| Command | Action |
| :--- | :--- |
| `pnpm day <dayXX> <input file path>` | Starts the application in **development mode** (if configured). |
| `pnpm test <dayXX>` | Runs the **project's test suite**. |
