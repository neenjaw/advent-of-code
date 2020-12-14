'use strict'

const fs = require('fs')
const { argv } = require('process')

const fileRead = fs.readFileSync(argv[2], { encoding: 'utf8', flag: 'r' })
const input = fileRead.trimEnd()

const [startWaitingTimeStr, buses] = input.split('\n')

const startWaitingTime = Number(startWaitingTimeStr)

const busList = buses
  .split(',')
  .map((busId, ord) => {
    const busNumber = Number(busId)

    if (isNaN(busNumber)) {
      return busId
    }

    return { arrivalTime: busNumber, busNumber, ordinal: ord }
  })
  .filter((busNumber) => busNumber !== 'x')

let answer = undefined

let time = 0
let waiting = false
let arrivalList = busList.sort(({ busNumber: a }, { busNumber: b }) => a - b)
while (!answer) {
  if (!waiting && time >= startWaitingTime) {
    waiting = true
  }

  if (arrivalList[0].arrivalTime > time) {
    time += 1
    continue
  }

  if (arrivalList[0].arrivalTime === time) {
    if (waiting) {
      answer = arrivalList[0].busNumber
      break
    }

    while (arrivalList[0].arrivalTime === time) {
      const { busNumber, ordinal } = arrivalList.shift()

      const nextArrival = { arrivalTime: time + busNumber, busNumber, ordinal }

      const scheduleBeforeIndex = arrivalList.findIndex(
        ({ arrivalTime }) => arrivalTime > nextArrival.arrivalTime
      )

      if (scheduleBeforeIndex === -1) {
        arrivalList.push(nextArrival)
      } else {
        arrivalList.splice(scheduleBeforeIndex, 0, nextArrival)
      }
    }
  }

  time += 1
}

console.log(answer)
console.log(time - startWaitingTime)
console.log(answer * (time - startWaitingTime))
