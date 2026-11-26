pub fn part1(input: &str) -> String {
    input.lines().count().to_string()
}

pub fn part2(input: &str) -> Option<String> {
    Some(input.len().to_string())
}

#[cfg(test)]
mod tests {
    use super::{part1, part2};

    #[test]
    fn part1_sample() {
        let input = include_str!("../samples/part1.txt");
        assert_eq!(part1(input), "3");
    }

    #[test]
    fn part2_sample() {
        let input = include_str!("../samples/part2.txt");
        assert_eq!(part2(input), Some("10".to_string()));
    }
}
