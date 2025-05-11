package main

import (
	"advent-of-go/util/conv"
	"advent-of-go/util/file"
	"advent-of-go/util/mapfunc"
	"errors"
	"log"
	"regexp"
	"strconv"
	"strings"
)

const inputFilePath = "./input.txt"

type Passport struct {
	byr int
	iyr int
	eyr int
	hgt string
	hcl string
	ecl string
	pid string
}

func requiredPassportProps() []string {
	return []string{"byr", "iyr", "eyr", "hgt", "hcl", "ecl", "pid"}
}

func makeFromFields(fields []string) (p Passport, e error) {
	props := make(map[string]string, len(fields))
	for _, field := range fields {
		pair := strings.SplitN(field, ":", 2)
		props[pair[0]] = pair[1]
	}

	if !mapfunc.ContainsAllKeys(props, requiredPassportProps()) {
		return p, errors.New("missing required prop")
	}

	byr, _ := strconv.Atoi(props["byr"])
	p.byr = byr
	eyr, _ := strconv.Atoi(props["eyr"])
	p.eyr = eyr
	iyr, _ := strconv.Atoi(props["iyr"])
	p.iyr = iyr
	p.hgt = props["hgt"]
	p.pid = props["pid"]
	p.ecl = props["ecl"]
	p.hcl = props["hcl"]
	return
}

func parseGroupsToPassports(groups []string) (passports []Passport) {
	for _, group := range groups {
		fields := strings.Fields(group)

		if len(fields) >= 7 {
			passport, err := makeFromFields(fields)
			if err == nil {
				passports = append(passports, passport)
			}
		}
	}
	return
}

func main() {
	input, err := file.ReadFile(inputFilePath)

	if err != nil {
		log.Fatal(err)
		return
	}

	groups := conv.SplitInputByString(input, "\n\n")
	passports := parseGroupsToPassports(groups)

	answer1 := len(passports)
	log.Printf("Part 1: %v", answer1)

	answer2 := countValidPassports(passports)
	log.Printf("Part 2: %v", answer2)
}

func countValidPassports(passports []Passport) (c int) {
	for _, passport := range passports {
		if validatePassport(passport) {
			c++
		}
	}
	return
}

func validatePassport(passport Passport) bool {
	validations := []func(Passport) bool{
		validateBirthYear,
		validateIssueYear,
		validateExpirationYear,
		validatePassportId,
		validateHeight,
		validateHairColor,
		validateEyeColor,
	}

	for _, validation := range validations {
		if !validation(passport) {
			return false
		}
	}
	return true
}

func validateBirthYear(passport Passport) bool {
	return passport.byr >= 1920 && passport.byr <= 2002
}

func validateIssueYear(passport Passport) bool {
	return passport.iyr >= 2010 && passport.iyr <= 2020
}

func validateExpirationYear(passport Passport) bool {
	return passport.eyr >= 2020 && passport.eyr <= 2030
}

func validatePassportId(passport Passport) bool {
	return len(passport.pid) == 9
}

func validateHeight(passport Passport) bool {
	r := regexp.MustCompile(`(?P<value>\d+)(?P<unit>[^\d]*)?`)
	result := r.FindAllStringSubmatch(passport.hgt, -1)
	names := r.SubexpNames()
	m := map[string]string{}
	for i, n := range result[0] {
		m[names[i]] = n
	}
	value, _ := strconv.Atoi(m["value"])
	switch m["unit"] {
	case "cm":
		return value >= 150 && value <= 193
	case "in":
		return value >= 59 && value <= 76
	default:
		return false
	}
}

func validateHairColor(passport Passport) bool {
	r := regexp.MustCompile(`^#[0-9a-f]{6}$`)
	return r.Match([]byte(passport.hcl))
}

func validateEyeColor(passport Passport) bool {
	r := regexp.MustCompile(`^(amb|blu|brn|grn|gry|hzl|oth)$`)
	return r.Match([]byte(passport.ecl))
}
