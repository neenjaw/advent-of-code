<?php

require __DIR__ . '/../vendor/autoload.php';

if ($argc !== 3) {
    echo "Usage: php bin/run.php <day_number> <input_file_path>\n";
    echo "Example: php bin/run.php day01 input.txt\n";
    exit(1);
}

// $argv[0] is the script name (bin/run.php)
// $argv[1] is the day string (e.g., 'day01')
// $argv[2] is the file path (e.g., 'input.txt')
$dayArg = $argv[1];
$inputFilePath = $argv[2];

$dayDirectory = ucfirst(strtolower($dayArg));

$fqcn = "\\Aoc\\{$dayDirectory}\\Solution";

if (!class_exists($fqcn)) {
    echo "Error: Solution class not found for {$dayArg}. Looking for: {$fqcn}\n";
    exit(1);
}

try {
    $solver = new $fqcn();

    $result = $solver->run($inputFilePath);

    echo $result . "\n";
} catch (\Throwable $e) {
    echo "An unexpected error occurred during execution:\n";
    echo "{$e->getMessage()} in {$e->getFile()}:{$e->getLine()}\n";
    exit(1);
}
