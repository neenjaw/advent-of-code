# Test runner - loads the test file from the parent directory
parent_dir = Path.expand("..", __DIR__)
Code.require_file(".scripts/utils.exs", parent_dir)
Code.require_file("solution.exs", parent_dir)

ExUnit.start()

# Load the test file from the root directory
Code.require_file("test.exs", parent_dir)
