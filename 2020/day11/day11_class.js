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

const start = new Date().getTime()
const occupied = new SeatingArrangement(layout, {}).settle().occupiedSeats
const end = new Date().getTime()

const delta = end - start

console.log(`${occupied} computed in ${delta}ms`)
