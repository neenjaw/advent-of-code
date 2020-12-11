'use strict'

const fs = require('fs')
const { argv } = require('process')
const {
  SeatingArrangement,
  // canSeeOccupiedSeat,
  // adjacentOccupiedSeat,
} = require('./lib')

const fileRead = fs.readFileSync(argv[2], { encoding: 'utf8', flag: 'r' })
const input = fileRead.trimEnd()

const layout = input.split('\n').map((line) => line.split(''))

console.log(new SeatingArrangement(layout, {}).settle().occupiedSeats)
