<?php

declare (strict_types = 1);

use Utils\Arr;
use Utils\File;

class Solution
{
    public function runPart1(string $input_filename): int
    {
        return $input_filename
        |> File::readFileLines(...)
        |> Arr::mapWith(fn(string $bank) => $this->pairVoltage($bank))
        |> array_sum(...);
    }

    public function pairVoltage(string $bank): int
    {
        $idxs = range(0, strlen($bank) - 1);
        $initial = array_slice($idxs, 0, 2);
        $rest = array_slice($idxs, 2);

        $best_voltage = array_reduce(
            array: $rest,
            callback: function (array $best, int $battery_idx) use ($bank): array {
                [$a, $b] = $best;

                $options = [
                    [$a, $b],
                    [$a, $battery_idx],
                    [$b, $battery_idx],
                ];

                $max_by = function (array | null $max, array $current) use ($bank): array {
                    if (!$max) {
                        return $current;
                    }

                    [$a1, $a2] = $max;
                    [$b1, $b2] = $current;

                    $a = (int) ($bank[$a1] . $bank[$a2]);
                    $b = (int) ($bank[$b1] . $bank[$b2]);

                    if ($a >= $b) {
                        return $max;
                    } else {
                        return $current;
                    }
                };

                return array_reduce($options, $max_by);
            },
            initial: $initial
        );

        return (int) ($bank[$best_voltage[0]] . $bank[$best_voltage[1]]);
    }

    public function runPart2(string $input_filename): int
    {
        return $input_filename
        |> File::readFileLines(...)
        |> Arr::mapWith(fn(string $bank) => $this->pairVoltage2($bank))
        |> array_sum(...);
    }

    public function pairVoltage2(string $bank): int
    {
        $on_count = 12;
        $idxs = range(0, strlen($bank) - 1);
        $initial = array_slice($idxs, 0, $on_count);
        $rest = array_slice($idxs, $on_count);

        $best_voltage = array_reduce(
            array: $rest,
            callback: function (array $best, int $battery_idx) use ($bank): array {
                $generated_options = array_map(
                    callback: function (int $idx) use ($best, $battery_idx): array {
                        $t_arr = $best;
                        unset($t_arr[$idx]);
                        $t_arr[] = $battery_idx;
                        return array_values($t_arr);
                    },
                    array: range(0, 11)
                );

                $options = [
                    $best,
                    ...$generated_options,
                ];

                $max_by = function (array | null $max, array $current) use ($bank): array {
                    if (!$max) {
                        return $current;
                    }

                    $a = $this->getBankValue($bank, $max);
                    $b = $this->getBankValue($bank, $current);

                    if ($a >= $b) {
                        return $max;
                    } else {
                        return $current;
                    }
                };

                return array_reduce($options, $max_by);
            },
            initial: $initial
        );

        return $this->getBankValue($bank, $best_voltage);
    }

    private function getBankValue(string $bank, array $idxs): int
    {
        return (int) array_reduce($idxs, fn(string $t, int $idx): string => $t . $bank[$idx], "");
    }
}
