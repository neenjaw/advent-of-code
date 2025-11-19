<?php

declare(strict_types=1);

use PHPUnit\Framework\TestCase;

final class SolutionTest extends TestCase
{
    public function testSolutionRuns(): void
    {
        $result = new Solution()->run('input.txt');

        $this->assertEquals(
            expected: 'Hello, World! The input is input.txt.',
            actual: $result
        );
    }
}
