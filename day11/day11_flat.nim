import os, strutils, sequtils, sugar, times

#[
This is a single array based implementation of Advent of Code Day 11 - part 2
]#


const emptySeat = 'L'
const occupiedSeat = '#'
const floor = '.'

# convert the array to a string format
proc strLayout(layout: seq[char], height:int, width: int): string =
  var output = newSeq[char](height * width + height)

  for y in 0..<height:
    for x in 0..<width:
      let idx = y * width + x + y
      output[idx] = layout[y * width + x]

    output[y * width + width + y] = '\n'

  return join(output, "")

# total the number of occupied chairs
proc occupied(layout: seq[char]): int =
  return layout.map(seat => (if seat == '#': 1 else: 0)).foldl(a + b)


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

# starting at a coordinate, look for the next chair that can be seen, count occupied chairs
proc lookAtVector(layout: seq[char], y: int, x: int, height: int, width: int): int =
  var count: int = 0

  for (dy, dx) in directions:
    var doneLooking = false
    var y1 = y
    var x1 = x

    while not doneLooking:
      y1 += dy
      x1 += dx

      if y1 in 0 ..< height and x1 in 0 ..< width:
        let idx = y1 * width + x1

        if layout[idx] == emptySeat:
          doneLooking = true
        if layout[idx] == occupiedSeat:
          count += 1
          doneLooking = true
      else:
        doneLooking = true

  return count

# Performs the conway game of life according to the rules
proc dance(layout: seq[char], height: int, width: int, size: int): (bool, seq[char]) =
  var changed = false
  var nextLayout = newSeq[char](size)

  for y in 0 ..< height:
    for x in 0 ..< width:
      let idx = y * width + x
      let seat = layout[idx]
      if seat == floor:
        nextLayout[idx] = seat
        continue

      let surroundingOccupied = lookAtVector(layout, y, x, height, width)

      if seat == emptySeat and surroundingOccupied == 0:
        changed = true
        nextLayout[idx] = occupiedSeat
      elif seat == occupiedSeat and surroundingOccupied >= 5:
        changed = true
        nextLayout[idx] = emptySeat
      else:
        nextLayout[idx] = seat

  return (changed, nextLayout)

# read the file as a whole to get the dimensions lazily
let filename = commandLineParams()[0]
var input = readFile(filename)
                .strip()
                .split('\n')
                .map(line => toSeq(line.items))

# find the characteristics of the layout
let height = input.len
let width = input[0].len
let size = height * width
var arr = newSeq[char](size)

# read the file again into a single array
var i = 0
for item in readFile(filename).items:
  if item != '\n':
    arr[i] = item
    i += 1

# run until settled
var settled = false
let startTime = cpuTime()
while not settled:
  let (changes_present, dance_result) = dance(arr, height, width, size)
  arr = dance_result
  if not changes_present:
    settled = true
let endTime = cpuTime() - startTime

echo strLayout(arr, height, width)
echo occupied(arr)
echo endTime
