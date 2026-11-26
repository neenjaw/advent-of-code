(ns aoc.runner
  "Command-line runner. Puzzle functions remain independent of file I/O."
  (:require [aoc.solution :as solution]))

(defn -main
  [& args]
  (when (> (count args) 1)
    (throw (ex-info "Usage: clojure -M:run [input-file]" {})))
  (let [input-file (or (first args) "input.txt")
        input (slurp input-file)]
    (println "Part 1:" (solution/part-1 input))
    (when-let [part-2 (ns-resolve 'aoc.solution 'part-2)]
      (println "Part 2:" (part-2 input)))))
