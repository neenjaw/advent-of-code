use regex::Regex;

fn main() {
    let input = include_str!("../../input.txt");
    let output = part1(input);
    dbg!(output);
}

fn part1(input: &str) -> String {
    let re = Regex::new(r"mul\((\d+),(\d+)\)").unwrap();
    let mut sum: i32 = 0;

    input.lines().for_each(|line| {
        re.captures_iter(line).for_each(|cap| {
            sum += cap[1].parse::<i32>().unwrap() * cap[2].parse::<i32>().unwrap();
        });
    });

    sum.to_string()
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_part1() {
        let input = include_str!("../../example.txt");
        assert_eq!(part1(input), "161");
    }
}
