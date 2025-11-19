import { readFile } from "node:fs/promises";

/**
 * Reads the entire file content and splits it into an array of lines.
 * @param filePath The path to the input file.
 * @returns A promise that resolves to an array of string lines.
 */
export async function readInputLines(filePath: string): Promise<string[]> {
  const content = await readFile(filePath, "utf-8");
  // Splits by any line ending (\r\n or \n) and filters out the last empty line if file ends with a newline.
  return content.split(/\r?\n/).filter((line) => line !== "");
}

/**
 * The standard interface for an Advent of Code solution.
 */
export interface Solver {
  (input: string[]): Promise<any>;
}
