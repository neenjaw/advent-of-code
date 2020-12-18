/* eslint-disable no-case-declarations */
'use strict'

const fs = require('fs')
const { argv } = require('process')

Array.prototype.peek = function () {
  return this[this.length - 1]
}

Array.prototype.isEmpty = function () {
  return this.length === 0
}

function evaluateExpression(expression) {
  const parts = expression.split('').filter((char) => char !== ' ')

  return evaluateParts(parts)
}

const ADDITION = '+'
const MULTIPLICATION = '*'
const LEFT_BRACKET = '('
const RIGHT_BRACKET = ')'

const OPERATIONS = {
  [ADDITION]: (a, b) => a + b,
  [MULTIPLICATION]: (a, b) => a * b,
  [LEFT_BRACKET]: null,
  [RIGHT_BRACKET]: null,
}

function evaluateParts(expression) {
  const contextStack = []
  let current = { value: 0, pendingOp: ADDITION }

  for (const part of expression) {
    const numberValue = Number(part)
    if (!isNaN(numberValue)) {
      if (current.pendingOp) {
        current.value = OPERATIONS[current.pendingOp](
          current.value,
          numberValue
        )
        current.pendingOp = null
      } else {
        current.value = numberValue
      }
      continue
    }

    switch (part) {
      case LEFT_BRACKET:
        current.reason = LEFT_BRACKET
        contextStack.push(current)
        current = { value: 0, pendingOp: ADDITION }
        break

      case ADDITION:
        current.pendingOp = part
        break
      case MULTIPLICATION:
        current.pendingOp = part
        contextStack.push(current)
        current = { value: 0, pendingOp: ADDITION }
        break

      case RIGHT_BRACKET:
        let foundMatch = false
        while (!contextStack.isEmpty() && !foundMatch) {
          const { value, pendingOp, reason } = contextStack.pop()
          current.value = OPERATIONS[pendingOp](value, current.value)

          if (reason === LEFT_BRACKET) {
            foundMatch = true
          }
        }
        current.pendingOp = null
        break

      default:
        throw new Error(`Unsupported operation: ${part}`)
    }
  }

  while (!contextStack.isEmpty()) {
    const { value, pendingOp } = contextStack.pop()
    current.value = OPERATIONS[pendingOp](value, current.value)
  }

  return current.value
}

const result = fs
  .readFileSync(argv[2], { encoding: 'utf8', flag: 'r' })
  .trimEnd()
  .split('\n')
  .map(evaluateExpression)
  .reduce((sum, value) => sum + value, 0)

console.log(`Solution: ${result}`)
