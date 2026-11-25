import { readFile } from "node:fs/promises";
import { resolve } from "node:path";

const inputPath = resolve(process.cwd(), process.argv[2] ?? "input.txt");
const input = await readFile(inputPath, "utf8");
const solution = await import("../index.js");

if (typeof solution.solvePart1 !== "function") {
  throw new TypeError("index.js must export a solvePart1(input) function.");
}

console.log(`Part 1: ${solution.solvePart1(input)}`);

if (typeof solution.solvePart2 === "function") {
  console.log(`Part 2: ${solution.solvePart2(input)}`);
}
