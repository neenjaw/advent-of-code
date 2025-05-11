'use strict'

const fs = require('fs')
const { argv } = require('process')

const fileRead = fs.readFileSync(argv[2], { encoding: 'utf8', flag: 'r' })
const input = fileRead.trimEnd()

const layout = input.split('\n')

/**
Action N means to move north by the given value.
Action S means to move south by the given value.
Action E means to move east by the given value.
Action W means to move west by the given value.
Action L means to turn left the given number of degrees.
Action R means to turn right the given number of degrees.
Action F means to move forward by the given value in the direction the ship is currently facing.
*/

const distance = layout.reduce(
  ([accY, accX, rotation], instruction) => {
    const direction = instruction[0]
    const amount = Number(instruction.substring(1))

    console.log({ instruction, direction, amount })

    switch (direction) {
      case 'N':
        accY += amount
        break
      case 'S':
        accY -= amount
        break
      case 'E':
        accX += amount
        break
      case 'W':
        accX -= amount
        break

      case 'L':
        rotation += amount
        rotation %= 360
        break

      case 'R':
        rotation -= amount
        if (rotation < 0) {
          rotation += 360
        }
        break

      case 'F':
        if (rotation == 0) {
          accX += amount
        } else if (rotation == 90) {
          accY += amount
        } else if (rotation == 180) {
          accX -= amount
        } else if (rotation == 270) {
          accY -= amount
        } else {
          throw new Error(
            `instruction received: ${instruction}, current rotation unsupported ${rotation}`
          )
        }
        break

      default:
        throw new Error(`instruction received: ${instruction}`)
    }

    return [accY, accX, rotation]
  },
  [0, 0, 0]
)

console.log(Math.abs(distance[0]) + Math.abs(distance[1]))
