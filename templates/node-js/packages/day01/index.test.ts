// packages/day01/index.test.ts
import { test, describe, before } from "node:test";
import * as assert from "node:assert/strict";
import { readInputLines } from "@aoc/common/index.ts";
import solve from "./index.ts";
import { fileURLToPath } from "url";
import { dirname } from "path";

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

const samplePath = __dirname + "/input.txt";
let sampleInput: string[] = [];

describe("Day 01 Solver", async () => {
  before(async () => {
    sampleInput = await readInputLines(samplePath);
  });

  test("Part 1 should return the expected result", async () => {
    const expectedResult = 4;

    const result = await solve(sampleInput);

    assert.strictEqual(
      result.part1,
      expectedResult,
      "Part 1 failed: Result mismatch"
    );
  });

  test("Part 2 should return the expected result", async () => {
    const expectedResult = "TBD"; // Placeholder

    const result = await solve(sampleInput);

    assert.strictEqual(
      result.part2,
      expectedResult,
      "Part 2 failed: Result mismatch"
    );
  });
});
