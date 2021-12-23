(ns net.aleonard.adventofcode.2020.1
    (:require [clojure.string :as s]
              [clojure.math.combinatorics :as comb]))

(defn part-1-naive
    [expenses]
    (let [factors (comb/combinations expenses 2)]
      (reduce * (first (filter #(= 2020 (reduce + %)) factors)))))

; short-circuiting variant for improved speed
(defn part-1
    [expenses]
    (loop [vals expenses
           check-vals {}]
          (if (check-vals (first vals))
            (* (check-vals (first vals)) (first vals))
            (recur (rest vals) (conj check-vals [(- 2020 (first vals)) (first vals)])))))

(defn part-2-naive
    [expenses]
    (let [factors (comb/combinations expenses 3)]
      (reduce * (first (filter #(= 2020 (reduce + %)) factors)))))

(defn- check-vals-with-new
    [check-vals base-vals new-val]
    (let [combos (map #(list (- 2020 new-val %) [new-val % base-vals]))]
      (conj check-vals (filter #(check-vals (first %)) combos))))

(defn part-2
    [expenses]
    (loop [vals (sort expenses)
           check-vals {}
           base-vals #{}]
          (if (check-vals (first vals))
            (reduce * (conj (check-vals (first vals)) (first vals)))
            (recur (rest vals) (check-vals-with-new check-vals base-vals (first vals)) (conj base-vals (first vals))))))

(defn -main
    [& args]
    (let [in-data (s/split-lines (slurp ((first args) :filename)))
          expenses (map #(Integer/parseInt %) in-data)]
      (println (str "Part 1:" (part-1-naive expenses)))
      (println (str "Part 2:" (part-2-naive expenses)))))
