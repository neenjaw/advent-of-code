(ns advent-of-clojure.core
  (:require [clojure.string :as string])
  (:use [clansi :only [style]]))

(defn read-input
  [day]
  (slurp (clojure.java.io/resource day)))

(defn call-aoc
  [year day part input]
  (require (symbol (format "advent-of-clojure.aoc-%4d.day-%02d" year day)))
  (apply (resolve (symbol (format "advent-of-clojure.aoc-%4d.day-%02d/part-%d" year day part))) [input]))

(defn run-part
  [year day part configs]
  (println (str ">> Part " part ":"))
  (loop [[config & rest] configs]
    (let [[file expected] config
          input (read-input (format "day-%02d.%s.txt" day (name file)))
          answer (call-aoc year day part input)]
      (print (str "File: " file))
      (if (= answer expected)
        (do
          (println (str ", success: " (style answer :green :underline)))
          (if rest (recur rest)))
        (println (str ", wanted: " (style expected :yellow) ", got: " (style answer :red)))))))

(defn run
  [year day]
  (case [year day]
    [2021 1] (do
               (run-part
                year day 1
                '([:example 7]
                  [:input, 1754]))

               (run-part
                year day 2
                '([:example 5]
                  [:input, 1789])))

    [2021 2] (do
               (run-part
                year day 1
                '([:example, 150]
                  [:input, 2150351]))

               (run-part
                year day 2
                '([:example, 900]
                  [:input, 1842742223])))

    [2021 3] (do
               (run-part
                year day 1
                '([:example, 198]
                  [:input, 4174964]))

               (run-part
                year day 2
                '([:example, 230]
                  [:input, 4474944])))

    (println (str "AoC " year " exercise day " day " not implemented."))))

(defn -main
  "Used to dispatch tasks from the command line."
  [part]
  (->>
   (string/split part #"\.")
   (map #(Integer/parseInt %))
   (apply run)))
