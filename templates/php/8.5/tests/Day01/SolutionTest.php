<?php

declare (strict_types = 1);

use Aoc\Day01\Solution;
use PHPUnit\Framework\TestCase;

final class SolutionTest extends TestCase
{
    public function testDay01Runs(): void
    {
        $result = new Solution()->run('some_file.txt');

        $this->assertEquals(
            expected: 'Hello, World! The input is some_file.txt.',
            actual: $result
        );
    }
}
