<?php

declare(strict_types=1);

namespace Aoc;

class Utility
{
    /**
     * Reads a file and returns an array of lines.
     */
    public static function readFileLines(string $filename, bool $skipEmptyLines = true): array
    {
        if (!file_exists($filename)) {
            die("Error: Input file not found at '{$filename}'\n");
        }

        $flags = FILE_IGNORE_NEW_LINES;
        if ($skipEmptyLines) {
            $flags |= FILE_SKIP_EMPTY_LINES;
        }

        $lines = file($filename, $flags);

        return $lines !== false ? $lines : [];
    }
}
