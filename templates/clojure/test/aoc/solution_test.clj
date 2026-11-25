(ns aoc.solution-test
  (:require [clojure.java.io :as io]
            [clojure.test :refer [deftest is]]
            [aoc.solution :as solution]))

(defn- sample
  [filename]
  (slurp (io/resource filename)))

(deftest part-1-sample
  (is (= 6 (solution/part-1 (sample "samples/part1.txt")))))

(deftest part-2-sample
  (is (= 9 (solution/part-2 (sample "samples/part2.txt")))))
