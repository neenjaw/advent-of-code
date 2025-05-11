use regex::Regex;

fn main() {
    let input = include_str!("../../input.txt");
    let output = part1(input);
    dbg!(output);
}

fn part1(input: &str) -> String {
    let re = Regex::new(r"(\d+)\s+(\d+)").unwrap();
    let mut left: Vec<i32> = Vec::new();
    let mut right: Vec<i32> = Vec::new();

    input.lines().for_each(|line| {
        re.captures_iter(line).for_each(|cap| {
            left.push(cap[1].parse::<i32>().unwrap());
            right.push(cap[2].parse::<i32>().unwrap());
        });
    });

    // sort the vectors
    left.sort();
    right.sort();

    // zip the vectors together
    left.iter()
        .zip(right.iter())
        .map(|(l, r)| (r - l).abs())
        .sum::<i32>()
        .to_string()
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_part1() {
        let input = include_str!("../../example.txt");
        assert_eq!(part1(input), "11");
    }
}
