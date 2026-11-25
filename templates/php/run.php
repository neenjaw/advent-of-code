<?php

declare(strict_types=1);

$autoload = __DIR__ . '/vendor/autoload.php';
if (is_file($autoload)) {
    require $autoload;
}

require __DIR__ . '/Solution.php';

$inputPath = $argv[1] ?? __DIR__ . '/input.txt';
$input = file_get_contents($inputPath);

if ($input === false) {
    fwrite(STDERR, "Could not read input file: {$inputPath}\n");
    exit(1);
}

$part1 = solvePart1($input);
echo 'Part 1: ' . ($part1 ?? 'not implemented') . PHP_EOL;

if (function_exists('solvePart2')) {
    $part2 = solvePart2($input);
    echo 'Part 2: ' . ($part2 ?? 'not implemented') . PHP_EOL;
}
