// @ts-check

/**
 * @typedef {string | number | bigint} Answer
 */

/**
 * Solve Part 1 using the raw puzzle input.
 *
 * This starter example sums the whitespace-separated numbers in the input.
 *
 * @param {string} input Raw puzzle input text.
 * @returns {Answer} The Part 1 answer.
 */
export function solvePart1(input) {
  return parseNumbers(input).reduce((sum, number) => sum + number, 0);
}

/**
 * Solve Part 2 using the raw puzzle input.
 *
 * This starter example multiplies the whitespace-separated numbers in the input.
 * Remove this function if a puzzle has no second part.
 *
 * @param {string} input Raw puzzle input text.
 * @returns {Answer} The Part 2 answer.
 */
export function solvePart2(input) {
  return parseNumbers(input).reduce((product, number) => product * number, 1);
}

/**
 * Parse whitespace-separated numbers from raw input.
 *
 * @param {string} input Raw puzzle input text.
 * @returns {number[]} The parsed numbers.
 */
function parseNumbers(input) {
  const values = input.trim().split(/\s+/).filter(Boolean);
  return values.map(Number);
}
