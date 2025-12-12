<?php

declare (strict_types = 1);

namespace Utils;

class File
{
    /**
     * Reads a file and returns an array of lines.
     */
    public static function readFileLines(string $filename): array
    {
        if (!file_exists($filename)) {
            die("Error: Input file not found at '{$filename}'\n");
        }

        $lines = file($filename, FILE_IGNORE_NEW_LINES);

        return $lines !== false ? $lines : [];
    }
}
