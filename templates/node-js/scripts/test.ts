import { execSync } from "node:child_process";
import { resolve } from "node:path";

// Get the optional day argument (e.g., 'day01')
const dayArg = process.argv[2];

let testGlob: string;
let command: string;

if (dayArg) {
  // If an argument is provided (e.g., 'day01'), restrict the glob
  const dayNumber = dayArg.replace(/day/i, "").padStart(2, "0");
  testGlob = resolve(process.cwd(), "packages", `day${dayNumber}`, "*.test.ts");
  console.log(`\nRunning tests for Day ${dayNumber} (${testGlob})...`);
} else {
  // If no argument is provided, run all tests
  testGlob = resolve(process.cwd(), "packages", "**", "*.test.ts");
  console.log("\nRunning ALL tests...");
}

// Build the Node command. We still execute 'node --test'
// The command needs to be executed via 'sh' to expand the glob pattern correctly.
command = `node --test "${testGlob}"`;

try {
  // Execute the command synchronously
  execSync(command, { stdio: "inherit" });
} catch (error) {
  // Node's test runner will exit with a non-zero code on failure,
  // which will throw an error here. 'stdio: inherit' shows the output.
  process.exit(1);
}
