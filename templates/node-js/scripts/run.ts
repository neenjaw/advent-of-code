import { readInputLines, type Solver } from "../packages/common/index.ts";
import { resolve } from "node:path";

// Get day number and input file from command line arguments
const [dayArg, inputFile] = process.argv.slice(2);

if (!dayArg || !inputFile) {
  console.error("Usage: pnpm day <day-number> <input-file-path>");
  console.error("Example: pnpm day 01 input.txt");
  process.exit(1);
}

const dayNumber = dayArg.padStart(2, "0"); // Ensures '01', '02', etc.
const packageName = `@aoc/day${dayNumber}`;

async function runDay() {
  try {
    // 1. Dynamically import the solver module for the specified day
    // We use a try/catch around the import to handle missing day modules gracefully
    const modulePath = resolve(
      process.cwd(),
      "packages",
      `day${dayNumber}`,
      "index.ts"
    );
    const solverModule = await import(modulePath);
    const solve: Solver = solverModule.default;

    if (typeof solve !== "function") {
      throw new Error(
        `Module ${packageName} does not export a default Solver function.`
      );
    }

    // 2. Resolve input file path relative to the day's package directory
    const inputPath = resolve(
      process.cwd(),
      "packages",
      `day${dayNumber}`,
      inputFile
    );
    const inputLines = await readInputLines(inputPath);

    console.log(`\nStarting Advent of Code Day ${dayNumber}`);
    console.log("---------------------------------");

    // 3. Run the solver and display the result
    const result = await solve(inputLines);

    console.log("---------------------------------");
    console.log("Finished successfully.");
    console.log("Overall Result:", result);
  } catch (error) {
    if (
      (error as any).code === "ERR_MODULE_NOT_FOUND" ||
      (error as any).code === "MODULE_NOT_FOUND"
    ) {
      console.error(`\nERROR: Day module ${packageName} not found.`);
      console.error(
        `Please make sure 'packages/day${dayNumber}' exists and has 'index.ts'.`
      );
    } else {
      console.error(
        `\nAn unexpected error occurred while running Day ${dayNumber}:`
      );
      console.error(error);
    }
    process.exit(1);
  }
}

runDay();
