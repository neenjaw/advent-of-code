input = [
  [[1,0,1],[1,2,1]],
  [[0,0,2],[2,0,2]],
  [[0,2,3],[2,2,3]],
  [[0,0,4],[0,2,4]],
  [[2,0,5],[2,2,5]],
  [[0,1,6],[2,1,6]],
  [[1,1,8],[1,1,9]],
]

ss = input.each_with_index.inject([]) do |ss, ((left, right), index)|
  left[2] = left[2]
  right[2] = right[2]
  s = "#{left.join(',')}~#{right.join(',')}"
  ss << s
end.join("\n") + "\n"

File.write('./builder.txt', ss)
