'use strict'

const fs = require('fs')
const { argv } = require('process')

const fileRead = fs.readFileSync(argv[2], { encoding: 'utf8', flag: 'r' })
const input = fileRead.trimEnd()

const [, buses] = input.split('\n')

const busList = buses
  .split(',')
  .map((busId, ord) => {
    const busNumber = Number(busId)

    if (isNaN(busNumber)) {
      return busId
    }

    return { busNumber, ordinance: ord }
  })
  .filter((busNumber) => busNumber !== 'x')

const findPeriodOfOffsetPeriod = (
  { time, periodOffset },
  { busNumber, ordinance }
) => {
  while ((time + ordinance) % busNumber !== 0) {
    time += periodOffset
  }
  periodOffset *= busNumber

  return { time, periodOffset }
}

const { time } = busList.reduce(findPeriodOfOffsetPeriod, {
  time: 0,
  periodOffset: 1,
})

console.log(time)
