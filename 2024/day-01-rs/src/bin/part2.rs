use regex::Regex;
use std::collections::HashMap;

fn main() {
    let input = include_str!("../../input.txt");
    let output = part2(input);
    dbg!(output);
}

fn part2(input: &str) -> String {
    let re = Regex::new(r"(\d+)\s+(\d+)").unwrap();
    let mut left_counts: HashMap<i32, i32> = HashMap::new();
    let mut left: Vec<i32> = Vec::new();
    let mut right: Vec<i32> = Vec::new();

    input.lines().for_each(|line| {
        re.captures_iter(line).for_each(|cap| {
            left_counts.insert(cap[1].parse::<i32>().unwrap(), 0);
            left.push(cap[1].parse::<i32>().unwrap());
            right.push(cap[2].parse::<i32>().unwrap());
        });
    });

    right.iter().for_each(|r| {
        if let Some(count) = left_counts.get_mut(r) {
            *count += 1;
        }
    });

    left.iter()
        .fold(0, |acc, r| {
            if let Some(count) = left_counts.get(r) {
                acc + r * count
            } else {
                acc
            }
        })
        .to_string()
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_part2() {
        let input = include_str!("../../example.txt");
        assert_eq!(part2(input), "31");
    }
}
