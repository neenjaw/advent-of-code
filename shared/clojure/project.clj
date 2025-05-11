(defproject advent-of-clojure "0.1.0-SNAPSHOT"
  :description "Advent of code solutions in clojure"
  :url "http://github.com/neenjaw/advent-of-clojure"
  :license {:name "EPL-2.0 OR GPL-2.0-or-later WITH Classpath-exception-2.0"
            :url "https://www.eclipse.org/legal/epl-2.0/"}
  :dependencies [[org.clojure/clojure "1.10.1"] [clansi "1.0.0"]]
  :main ^:skip-aot advent-of-clojure.core
  :target-path "target/%s"
  :profiles {:uberjar {:aot :all}})
