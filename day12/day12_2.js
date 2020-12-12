'use strict'

const fs = require('fs')
const { argv } = require('process')

const fileRead = fs.readFileSync(argv[2], { encoding: 'utf8', flag: 'r' })
const input = fileRead.trimEnd()

const routingInformation = input.split('\n')

/**
Action N means to move the waypoint north by the given value.
Action S means to move the waypoint south by the given value.
Action E means to move the waypoint east by the given value.
Action W means to move the waypoint west by the given value.
Action L means to rotate the waypoint around the ship left (counter-clockwise) the given number of degrees.
Action R means to rotate the waypoint around the ship right (clockwise) the given number of degrees.
Action F means to move forward to the waypoint a number of times equal to the given value.
*/

const distance = routingInformation.reduce(
  ({ accX, accY, rotation, waypointX, waypointY }, instruction) => {
    const direction = instruction[0]
    const amount = Number(instruction.substring(1))

    console.log({ instruction, direction, amount })

    switch (direction) {
      case 'N':
        waypointY += amount
        break
      case 'S':
        waypointY -= amount
        break
      case 'E':
        waypointX += amount
        break
      case 'W':
        waypointX -= amount
        break

      case 'L':
        const left_turns = (amount % 360) / 90
        for (let index = 0; index < left_turns; index++) {
          const newWaypointY = waypointX
          const newWaypointX = waypointY * -1
          waypointY = newWaypointY
          waypointX = newWaypointX
        }
        break

      case 'R':
        const right_turns = (amount % 360) / 90
        for (let index = 0; index < right_turns; index++) {
          const newWaypointY = waypointX * -1
          const newWaypointX = waypointY
          waypointY = newWaypointY
          waypointX = newWaypointX
        }
        break

      case 'F':
        accX += amount * waypointX
        accY += amount * waypointY
        break

      default:
        throw new Error(`instruction received: ${instruction}`)
    }

    console.log({ accX, accY, rotation, waypointX, waypointY })

    return { accX, accY, rotation, waypointX, waypointY }
  },
  { accX: 0, accY: 0, rotation: 0, waypointX: 10, waypointY: 1 }
)

console.log(
  `${Math.abs(distance.accX)} + ${Math.abs(distance.accY)} = ${
    Math.abs(distance.accX) + Math.abs(distance.accY)
  }`
)
