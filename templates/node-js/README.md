# Advent of Code Day Template

A standalone Node.js template for solving Advent of Code problems.

## Setup

1. Copy this entire folder to your day folder (e.g., `day01/`, `day02/`, etc.)
2. Run `npm install` to install dependencies
3. Edit `index.ts` with your solution
4. Add your input to `input.txt`

## Usage

### Run your solution
```bash
npm start
# or with a custom input file
npm start -- sample.txt
```

### Run tests
```bash
npm test
# or watch mode
npm run test:watch
```

## File Structure

- `index.ts` - Your solution (exports a default Solver function)
- `index.test.ts` - Your tests
- `input.txt` - Your puzzle input
- `utils.ts` - Common utilities (readInputLines, Solver interface)
- `scripts/run.ts` - Script to run your solution
- `package.json` - npm configuration and scripts
- `tsconfig.json` - TypeScript configuration (uses Node's native TypeScript support)

## Requirements

- Node.js 20+ (for native TypeScript support)
- npm

## Solution Format

Your `index.ts` should export a default function that matches the `Solver` interface:

```typescript
import type { Solver } from "./utils.ts";

const solve: Solver = async (input: string[]) => {
  // Your solution here
  return { part1: result1, part2: result2 };
};

export default solve;
```
