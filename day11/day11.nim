import os, strutils, sequtils, sugar, times

const emptySeat = 'L'
const occupiedSeat = '#'
const floor = '.'

proc strLayout(layout: seq[seq[char]]): string =
  return join(layout.map(row => join(row)), "\n")

proc occupied(layout: seq[seq[char]]): int =
  return layout.map(row => row.map(seat => (if seat == '#': 1 else: 0)).foldl(a + b)).foldl(a + b)


const directions = [
  (1, -1),
  (1, 0),
  (1, 1),
  (0, -1),
  (0, 1),
  (-1, -1),
  (-1, 0),
  (-1, 1)
]

# For part 1
proc lookAround(layout: seq[seq[char]], y: int, x: int): int =
  var count: int = 0

  for (dy, dx) in directions:
    let y1 = y + dy
    let x1 = x + dx

    if y1 in 0 ..< layout.len and x1 in 0 ..< layout[0].len and layout[y1][x1] == occupiedSeat:
      count += 1

  return count

# For part 2
proc lookAtVector(layout: seq[seq[char]], y: int, x: int): int =
  var count: int = 0

  for (dy, dx) in directions:
    var doneLooking = false
    var y1 = y
    var x1 = x
    while not doneLooking:
      y1 += dy
      x1 += dx

      if y1 in 0 ..< layout.len and x1 in 0 ..< layout[0].len:
        if layout[y1][x1] == emptySeat:
          doneLooking = true
        if layout[y1][x1] == occupiedSeat:
          count += 1
          doneLooking = true
      else:
        doneLooking = true

  return count

proc dance(layout: seq[seq[char]], occupiedThreshold: int = 5): (bool, seq[seq[char]]) =
  var changed = false
  var nextLayout = newSeq[seq[char]](layout.len)

  for y in 0 ..< layout.len:
    nextLayout[y] = newSeq[char](layout[0].len)

    for x in 0 ..< layout[0].len:
      # echo x, " ", y, layout[y][x]
      let seat = layout[y][x]
      if seat == floor:
        nextLayout[y][x] = seat
        continue

      let surroundingOccupied = lookAtVector(layout, y, x)

      if seat == emptySeat and surroundingOccupied == 0:
        changed = true
        nextLayout[y][x] = occupiedSeat
      elif seat == occupiedSeat and surroundingOccupied >= occupiedThreshold:
        changed = true
        nextLayout[y][x] = emptySeat
      else:
        nextLayout[y][x] = seat

  return (changed, nextLayout)

let filename = commandLineParams()[0]
var input = readFile(filename)
                .strip()
                .split('\n')
                .map(line => toSeq(line.items))


var settled = false
let startTime = cpuTime()
while not settled:
  let (changes_present, dance_result) = dance(input)
  input = dance_result
  if not changes_present:
    settled = true
let endTime = cpuTime() - startTime

echo strLayout(input)
echo occupied(input)
echo endTime
