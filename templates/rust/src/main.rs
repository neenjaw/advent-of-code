mod solution;

use std::env;
use std::error::Error;
use std::fs;
use std::process;

fn main() {
    if let Err(error) = run() {
        eprintln!("{error}");
        process::exit(1);
    }
}

fn run() -> Result<(), Box<dyn Error>> {
    let mut args = env::args().skip(1);
    let input_path = args.next().unwrap_or_else(|| "input.txt".to_string());

    if args.next().is_some() {
        return Err("Usage: cargo run -- [input-file]".into());
    }

    let input = fs::read_to_string(&input_path)?;

    println!("Part 1: {}", solution::part1(&input));

    if let Some(answer) = solution::part2(&input) {
        println!("Part 2: {answer}");
    }

    Ok(())
}
