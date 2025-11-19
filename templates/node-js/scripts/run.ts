import { readInputLines } from "../utils.ts";
import { resolve } from "node:path";
import { fileURLToPath } from "url";
import { dirname } from "path";

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

// Get input file from command line arguments (defaults to input.txt)
const inputFile = process.argv[2] || "input.txt";

async function runDay() {
  try {
    // Dynamically import the solver module
    const solverModule = await import("../index.ts");
    const solve = solverModule.default;

    if (typeof solve !== "function") {
      throw new Error(
        `Module does not export a default Solver function.`
      );
    }

    // Resolve input file path relative to the current directory
    const inputPath = resolve(process.cwd(), inputFile);
    const inputLines = await readInputLines(inputPath);

    console.log(`\nStarting Advent of Code Solution`);
    console.log(`Input file: ${inputFile}`);
    console.log("---------------------------------");

    // Run the solver and display the result
    const result = await solve(inputLines);

    console.log("---------------------------------");
    console.log("Finished successfully.");
    console.log("Overall Result:", result);
  } catch (error: any) {
    if (
      error.code === "ERR_MODULE_NOT_FOUND" ||
      error.code === "MODULE_NOT_FOUND"
    ) {
      console.error(`\nERROR: Could not find module or input file.`);
      console.error(`Please make sure 'index.ts' exists and '${inputFile}' is available.`);
    } else {
      console.error(`\nAn unexpected error occurred:`);
      console.error(error);
    }
    process.exit(1);
  }
}

runDay();
