'use strict'

const fs = require('fs')
const { argv } = require('process')

const fileRead = fs.readFileSync(argv[2], { encoding: 'utf8', flag: 'r' })
const input = fileRead.trimEnd()

const layout = input.split('\n').map((line) => line.split(''))

const OCCUPIED = '#'
const EMPTY = 'L'
const FLOOR = '.'
const LIMIT = 5

const DIRECTIONS = Object.freeze([
  [1, -1],
  [1, 0],
  [1, 1],
  [0, -1],
  [0, 1],
  [-1, -1],
  [-1, 0],
  [-1, 1],
])

function processRound(layout) {
  let changeCount = 0
  const changedLayout = layout.map((row, y) => {
    return row.map((seat, x) => {
      if (seat === FLOOR) {
        return FLOOR
      }

      const surroundingCount = DIRECTIONS.reduce((acc, [dy, dx]) => {
        if (layout[y + dy] === undefined) {
          return acc
        }

        return acc + (canSeeSeat(layout, y, x, dy, dx) ? 1 : 0)
      }, 0)

      if (seat === EMPTY && surroundingCount === 0) {
        // if the seat is empty and there are no seats in sight
        changeCount += 1
        return OCCUPIED
      } else if (seat === OCCUPIED && surroundingCount >= LIMIT) {
        // if the seat is occupied and the can see greater than the limit
        changeCount += 1
        return EMPTY
      } else {
        return seat
      }
    })
  })

  return [changedLayout, changeCount]
}

function run(layout) {
  let currentLayout = layout
  let done = false
  while (!done) {
    const [processed, changes] = processRound(currentLayout)

    if (changes === 0) {
      done = true
    }

    currentLayout = processed
  }

  return currentLayout
}

// console.log(processRound(layout))
const result = run(layout)
  .flat()
  .reduce((acc, seat) => {
    return acc + (seat === OCCUPIED ? 1 : 0)
  }, 0)

console.log(result)

function printLayout(layout) {
  return layout.map((row) => row.join('')).join('\n')
}

function canSeeSeat(layout, y, x, dy, dx) {
  const sawChair = false

  while (!sawChair) {
    y += dy
    x += dx

    if (layout[y] && layout[y][x]) {
      if (layout[y][x] === EMPTY) {
        return false
      }
      if (layout[y][x] === OCCUPIED) {
        return true
      }
    } else {
      return false
    }
  }

  return true
}
