<?php

declare(strict_types=1);

$autoload = __DIR__ . '/vendor/autoload.php';
if (is_file($autoload)) {
    require $autoload;
}

require __DIR__ . '/Solution.php';

$cases = [
    [
        'name' => 'Part 1 sample',
        'fixture' => 'sample.txt',
        'solve' => 'solvePart1',
        'expected' => null, // Replace with the expected sample answer.
    ],
    [
        'name' => 'Part 2 sample',
        'fixture' => 'sample.txt',
        'solve' => 'solvePart2',
        'expected' => null, // Replace with the expected sample answer.
    ],
];

$passed = 0;
$failed = 0;
$skipped = 0;

foreach ($cases as $case) {
    if ($case['expected'] === null) {
        echo "SKIP: {$case['name']} (expected answer not set)\n";
        $skipped++;
        continue;
    }

    $input = file_get_contents(__DIR__ . '/' . $case['fixture']);
    if ($input === false) {
        fwrite(STDERR, "Could not read fixture: {$case['fixture']}\n");
        $failed++;
        continue;
    }

    if (!function_exists($case['solve'])) {
        echo "SKIP: {$case['name']} ({$case['solve']} is not defined)\n";
        $skipped++;
        continue;
    }

    $actual = $case['solve']($input);
    if ($actual === $case['expected']) {
        echo "PASS: {$case['name']}\n";
        $passed++;
    } else {
        echo "FAIL: {$case['name']}\n";
        echo '  Expected: ' . var_export($case['expected'], true) . "\n";
        echo '  Actual:   ' . var_export($actual, true) . "\n";
        $failed++;
    }
}

echo "{$passed} passed, {$failed} failed, {$skipped} skipped\n";
exit($failed === 0 ? 0 : 1);
