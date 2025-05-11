(ns advent-of-clojure.aoc-2021.day-02)

(defn prep
  [input]
  (for [[_ command value] (re-seq #"(\w+)\s+(\d+)" input)]
    {:command (keyword command)
     :value (Long/parseLong value)}))

(def init-position
  {:aim 0 :horizontal 0 :depth 0})

(defn- compute
  [{:keys [horizontal depth]}]
  (* horizontal depth))

(defn- part-1-reducer [position {:keys [command value]}]
  (case command
    :forward (update position :horizontal + value)
    :down    (update position :depth + value)
    :up      (update position :depth - value)))

(defn- part-2-reducer [position {:keys [command value]}]
  (case command
    :forward (-> position
                 (update :horizontal + value)
                 (update :depth + (* (:aim position) value)))
    :down    (update position :aim  + value)
    :up      (update position :aim  - value)))

(defn- solve
  [reducer input]
  (->>
   (prep input)
   (reduce reducer init-position)
   compute))

(def part-1 (partial solve part-1-reducer))
(def part-2 (partial solve part-2-reducer))
