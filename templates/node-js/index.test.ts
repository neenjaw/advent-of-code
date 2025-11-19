import { test, describe, before } from "node:test";
import * as assert from "node:assert/strict";
import { readInputLines } from "./utils.ts";
import solve from "./index.ts";
import { fileURLToPath } from "url";
import { dirname, resolve } from "path";

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

const samplePath = resolve(__dirname, "input.txt");
let sampleInput: string[] = [];

describe("Solver", async () => {
  before(async () => {
    sampleInput = await readInputLines(samplePath);
  });

  test("Part 1 should return the expected result", async () => {
    const expectedResult = 8; // "test" (4) + "line" (4) = 8

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
