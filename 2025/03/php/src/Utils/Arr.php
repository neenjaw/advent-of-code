<?php

declare (strict_types = 1);

namespace Utils;

class Arr
{
    public static function mapWith(callable $callback): \Closure
    {
        return fn(array $arr): array=> array_map($callback, $arr);
    }

    /**
     * A pipe-able wrapper for array_filter.
     * @param callable $callback The filtering function.
     * @return \Closure A function that accepts the array and returns the filtered array.
     */
    public static function filterWith(callable $callback): \Closure
    {
        return fn(array $arr): array=> array_filter($arr, $callback);
    }
}
