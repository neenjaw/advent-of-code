
(ns advent-of-clojure.util
  (:require [clojure.string :as string]))

(defn sum
  [list]
  (reduce + list))
