const fs = require('fs')
const { argv } = require('process')

const fileRead = fs.readFileSync(argv[2], { encoding: 'utf8', flag: 'r' })
const input = fileRead.trimEnd()

const layout = input.split('\n').map((line) => line.split(''))

const OCCUPIED = '#'
const EMPTY = 'L'
const FLOOR = '.'

// console.log(layout)

const mutations = [
  [1, -1],
  [1, 0],
  [1, 1],
  [0, -1],
  [0, 1],
  [-1, -1],
  [-1, 0],
  [-1, 1],
]

function processRound(layout) {
  // if a seat is empty and there are no occupied seats adjacent to it, becomes occupied
  // if a seat is occupied and foure or more seats adjacent to it are accupied, seat becomes empty
  //  otherwise none
  let changes = 0
  const changed = layout.map((row, y) => {
    return row.map((seat, x) => {
      if (seat === FLOOR) {
        return FLOOR
      }

      const surroundingCount = mutations.reduce((acc, [dy, dx]) => {
        if (layout[y + dy] === undefined) {
          return acc
        }

        return acc + (canSeeSeat(layout, y, x, dy, dx) ? 1 : 0)
      }, 0)

      if (seat === EMPTY && surroundingCount === 0) {
        changes += 1
        return OCCUPIED
      } else if (seat === OCCUPIED && surroundingCount >= 5) {
        changes += 1
        return EMPTY
      } else {
        return seat
      }
    })
  })

  // console.log(printLayout(changed))
  return [changed, changes]
}

function run(layout) {
  let round = 0
  let currentLayout = layout
  let done = false
  while (!done) {
    round += 1
    console.log(`round: ${round}`)

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
  sawChair = false

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
