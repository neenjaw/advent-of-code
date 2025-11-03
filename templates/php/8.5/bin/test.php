<?php

require __DIR__ . '/../vendor/autoload.php';

if ($argc < 2) {
    echo "Usage: php bin/test.php <day_number>\n";
    echo "Example: php bin/test.php day01\n";
    exit(1);
}

// $argv[1] is the day string (e.g., 'day01')
$dayArg = $argv[1];

// day01 -> tests/Day01
$dayDirectory = ucfirst(strtolower($dayArg));
$testPath = __DIR__ . "/../tests/{$dayDirectory}";

if (!is_dir($testPath)) {
    echo "Error: Test directory not found for {$dayArg}.\n";
    echo "Expected directory: {$testPath}\n";
    exit(1);
}

$args = [
    '--configuration',
    'phpunit.xml',
    '--testsuite',
    'AdventOfCode',
    $testPath,
];

try {
    $application = new \PHPUnit\TextUI\Application();
    $exitCode = $application->run($args);
    exit($exitCode);
} catch (\Throwable $e) {
    echo "An unexpected error occurred during testing:\n";
    echo "{$e->getMessage()}\n";
    exit(255);
}
