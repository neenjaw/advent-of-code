<?php

require __DIR__ . '/../vendor/autoload.php';

if ($argc < 2) {
    echo "Usage: php bin/run.php <input_file_path>\n";
    echo "Example: php bin/run.php input.txt\n";
    exit(1);
}

$inputFilePath = $argv[1];

if (!class_exists('Solution')) {
    echo "Error: Solution class not found.\n";
    exit(1);
}

try {
    $solver = new Solution();
    $result = $solver->run($inputFilePath);
    echo $result . "\n";
} catch (\Throwable $e) {
    echo "An unexpected error occurred during execution:\n";
    echo "{$e->getMessage()} in {$e->getFile()}:{$e->getLine()}\n";
    exit(1);
}
