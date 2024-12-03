use regex::Regex;

fn main() {
    let input = include_str!("../../input.txt");
    let output = part2(input);
    dbg!(output);
}

fn part2(input: &str) -> String {
    let re = Regex::new(r"(mul\((\d{1,3}),(\d{1,3})\))|(do\(\))|(don't\(\))").unwrap();
    let mut run: bool = true;
    let mut sum: i32 = 0;

    input.lines().for_each(|line| {
        re.captures_iter(line).for_each(|cap| {
            match [cap.get(2), cap.get(3), cap.get(4), cap.get(5)] {
                [a, b, None, None] => {
                    if run {
                        sum += a.unwrap().as_str().parse::<i32>().unwrap()
                            * b.unwrap().as_str().parse::<i32>().unwrap();
                    }
                }
                [None, None, Some(_), None] => {
                    run = true;
                }
                [None, None, None, Some(_)] => {
                    run = false;
                }
                _ => {}
            }
        });
    });

    sum.to_string()
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_part2() {
        let input = include_str!("../../example_02.txt");
        assert_eq!(part2(input), "48");
    }
}
