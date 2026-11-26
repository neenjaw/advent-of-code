(ns aoc.solution
  "Puzzle logic for this day. Functions accept the complete raw input string."
  (:require [clojure.string :as str]))

(defn- parse-numbers
  [input]
  (map parse-long (str/split-lines input)))

(defn part-1
  "Scaffolding example: sum the numbers in the input."
  [input]
  (reduce + 0 (parse-numbers input)))

(defn part-2
  "Scaffolding example: find the largest number in the input."
  [input]
  (apply max (parse-numbers input)))
