import strutils, sequtils, sugar, sets, math

const filename = "input.txt"

echo readFile(filename).split("\n\n")
                       # .map(proc(g:string): string = g.strip()) # de-sugared
                       .map((group) => group.strip
                            .splitLines
                            .map((line) => line.toHashSet) # sugar-ed
                            .foldl(intersection(a, b)))
                        .map((x) => x.len)
                        .sum