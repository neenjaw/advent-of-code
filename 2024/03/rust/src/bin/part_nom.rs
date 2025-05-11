use nom::{
    branch::alt,
    bytes::complete::tag,
    character::complete::{anychar, digit1},
    multi::{many0, many_till},
    sequence::tuple,
    IResult,
};

fn main() {
    let input = include_str!("../../input.txt");
    let output = part2(input);
    dbg!(output);
}

#[derive(Debug, Clone)]
enum Instruction {
    Mul(i32, i32),
    Do,
    Dont,
}

fn parse_mul(input: &str) -> IResult<&str, Instruction> {
    let (input, (_, a, _, b, _)) = tuple((tag("mul("), digit1, tag(","), digit1, tag(")")))(input)?;
    Ok((
        input,
        Instruction::Mul(a.parse().unwrap(), b.parse().unwrap()),
    ))
}

fn parse_do(input: &str) -> IResult<&str, Instruction> {
    let (input, _) = tag("do()")(input)?;
    Ok((input, Instruction::Do))
}

fn parse_dont(input: &str) -> IResult<&str, Instruction> {
    let (input, _) = tag("don't()")(input)?;
    Ok((input, Instruction::Dont))
}

fn parse_any(input: &str) -> IResult<&str, Instruction> {
    alt((parse_mul, parse_do, parse_dont))(input)
}

fn parse_till(input: &str) -> IResult<&str, Instruction> {
    let (input, res) = many_till(anychar, parse_any)(input)?;
    Ok((input, res.1))
}

fn parse_instructions(input: &str) -> IResult<&str, Vec<Instruction>> {
    let (input, res) = many0(parse_till)(input)?;
    Ok((input, res))
}

fn part2(input: &str) -> String {
    let mut run: bool = true;
    let mut sum: i32 = 0;

    let result = parse_instructions(input);

    match result {
        Ok((_, instructions)) => {
            for instruction in instructions {
                match instruction {
                    Instruction::Mul(a, b) => {
                        if run {
                            sum += a * b;
                        }
                    }
                    Instruction::Do => {
                        run = true;
                    }
                    Instruction::Dont => {
                        run = false;
                    }
                }
            }
        }
        Err(e) => {
            println!("Error: {:?}", e);
        }
    }

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
