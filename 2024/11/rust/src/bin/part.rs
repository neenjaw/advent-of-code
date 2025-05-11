use regex::Regex;
use std::collections::HashMap;

fn main() {
    let input = include_str!("../../input");
    let output = part(input, 75);
    dbg!(output);
}

fn part(input: &str, iters: i64) -> String {
    let re = Regex::new(r"\b(\d+)\b").unwrap();
    let values: Vec<i64> = re
        .find_iter(input)
        .map(|m| m.as_str().parse::<i64>().unwrap())
        .collect();
    let mut stones: HashMap<i64, i64> = HashMap::new();
    values.iter().for_each(|&v| match stones.get_mut(&v) {
        Some(x) => {
            *x += 1;
        }
        None => {
            stones.insert(v, 1);
        }
    });

    for _ in 0..iters {
        let mut new_stones: HashMap<i64, i64> = HashMap::new();
        for (stone, count) in stones.iter() {
            let mut to_add = vec![];
            let digits = stone.to_string().len();
            if *stone == 0 {
                to_add.push((1, *count));
            } else if digits % 2 == 0 {
                let half = digits / 2;
                let left_half = stone.to_string()[..half as usize].parse::<i64>().unwrap();
                let right_half = stone.to_string()[half as usize..].parse::<i64>().unwrap();
                to_add.push((left_half, *count));
                to_add.push((right_half, *count));
            } else {
                to_add.push((*stone * 2024, *count));
            }
            for (new_stone, new_count) in to_add {
                match new_stones.get_mut(&new_stone) {
                    Some(x) => {
                        *x += new_count;
                    }
                    None => {
                        new_stones.insert(new_stone, new_count);
                    }
                }
            }
        }
        stones = new_stones;
    }

    stones.values().sum::<i64>().to_string()
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_part() {
        let input = include_str!("../../example2");
        assert_eq!(part(input, 25), "55312");
    }

    #[test]
    fn test_part() {
        let input = include_str!("../../input");
        assert_eq!(part(input, 25), "207683");
    }

    #[test]
    fn test_part() {
        let input = include_str!("../../example2");
        assert_eq!(part(input, 75), "244782991106220");
    }
}
