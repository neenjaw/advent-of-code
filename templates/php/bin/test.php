<?php

require __DIR__ . '/../vendor/autoload.php';

$args = [
    '--configuration',
    __DIR__ . '/phpunit.xml',
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
