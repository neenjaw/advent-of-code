import assert from "node:assert/strict";
import { readFileSync } from "node:fs";
import test from "node:test";
import { solvePart1, solvePart2 } from "./index.js";

const part1Sample = readFileSync(
  new URL("./samples/part1.txt", import.meta.url),
  "utf8",
);
const part2Sample = readFileSync(
  new URL("./samples/part2.txt", import.meta.url),
  "utf8",
);

test("Part 1 solves its sample", () => {
  assert.equal(solvePart1(part1Sample), 6);
});

test("Part 2 solves its sample", () => {
  assert.equal(solvePart2(part2Sample), 24);
});
