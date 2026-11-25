(ns aoc.test-runner
  (:require [clojure.test :as test]
            [aoc.solution-test]))

(defn -main
  [& _args]
  (let [{:keys [fail error]} (test/run-tests 'aoc.solution-test)]
    (when (pos? (+ fail error))
      (System/exit 1))))
