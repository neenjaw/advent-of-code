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

function processRound(layout, seatComparator) {
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

        return acc + (seatComparator(layout, y, x, dy, dx) ? 1 : 0)
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

class SeatingArrangement {
  constructor(
    initial,
    { limit = 5, seatComparator = canSeeOccupiedSeat, settleLimit = 1000 }
  ) {
    this.layout = initial
    this.limit = limit
    this.seatComparator = seatComparator
    this.settleLimit = settleLimit
  }

  get printLayout() {
    return this.layout.map((row) => row.join('')).join('\n')
  }

  get occupiedSeats() {
    return this.layout.flat().reduce((acc, seat) => {
      return acc + (seat === OCCUPIED ? 1 : 0)
    }, 0)
  }

  settle() {
    let currentLayout = this.layout
    let settled = false
    let rounds = 0
    while (!settled) {
      rounds += 1
      if (rounds > this.settleLimit) {
        throw new Error('too many rounds occurred before settling')
      }

      const [processed, changes] = processRound(
        currentLayout,
        this.seatComparator
      )

      if (changes === 0) {
        settled = true
      }
      currentLayout = processed
    }

    this.layout = currentLayout
    return this
  }
}

function canSeeOccupiedSeat(layout, y, x, dy, dx) {
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

function adjacentOccupiedSeat(layout, y, x, dy, dx) {
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

module.exports = {
  SeatingArrangement,
  canSeeOccupiedSeat,
  adjacentOccupiedSeat,
}
