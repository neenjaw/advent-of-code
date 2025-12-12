<?php

declare (strict_types = 1);

use PHPUnit\Framework\TestCase;

final class SolutionTest extends TestCase
{
    public function testSamplePart1(): void
    {
        $result = new Solution()->runPart1('sample.txt');
        $this->assertEquals(357, $result);
    }

    public function testSolutionPart1(): void
    {
        $result = new Solution()->runPart1('input.txt');

        $this->assertEquals(
            expected: 17316,
            actual: $result
        );
    }

    public function testSamplePart2(): void
    {
        $result = new Solution()->runPart2('sample.txt');
        $this->assertEquals(3121910778619, $result);
    }

    public function testSolutionPart2(): void
    {
        $result = new Solution()->runPart2('input.txt');

        $this->assertEquals(
            expected: 171741365473332,
            actual: $result
        );
    }
}
