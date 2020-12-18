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

const ADDITION = '+'
const MULTIPLICATION = '*'
const LEFT_BRACKET = '('
const RIGHT_BRACKET = ')'

const OPERATIONS = {
  [ADDITION]: (a, b) => a + b,
  [MULTIPLICATION]: (a, b) => a * b,
}

const OPERATORS = Object.keys(OPERATIONS)

const PRECEDENCE = {
  [ADDITION]: 3,
  [MULTIPLICATION]: 2,
}

function evaluateExpression(expression) {
  const tokens = expression.split('').filter((char) => char !== ' ')
  return evaluateTokens(tokens)
}

/**
 * @param {string[]} tokens
 */
function evaluateTokens(tokens) {
  return evaluateRPN(convertToRPN(tokens))
}

/**
 * Convert infix to postfix (reverse polish notation) using modified precedence rules
 * @param {string[]} tokens
 */
function convertToRPN(tokens) {
  const outputStack = []
  const operatorStack = []

  while (!tokens.isEmpty()) {
    const token = tokens.shift()
    const numericalValue = Number(token)

    if (!isNaN(numericalValue)) {
      outputStack.push(numericalValue)
    } else if (OPERATORS.includes(token)) {
      while (
        !operatorStack.isEmpty() &&
        PRECEDENCE[operatorStack.peek()] > PRECEDENCE[token]
      ) {
        outputStack.push(operatorStack.pop())
      }
      operatorStack.push(token)
    } else if (token === LEFT_BRACKET) {
      operatorStack.push(token)
    } else if (token === RIGHT_BRACKET) {
      while (
        !operatorStack.isEmpty() &&
        operatorStack.peek() !== LEFT_BRACKET
      ) {
        outputStack.push(operatorStack.pop())
      }
      if (operatorStack.peek() === LEFT_BRACKET) {
        operatorStack.pop()
      }
    }
  }
  while (!operatorStack.isEmpty()) {
    outputStack.push(operatorStack.pop())
  }

  return outputStack
}

function evaluateRPN(RPNTokens) {
  const numbers = []

  for (const token of RPNTokens) {
    if (typeof token === 'number') {
      numbers.push(token)
      continue
    }

    const b = numbers.pop()
    const a = numbers.pop()
    const result = OPERATIONS[token](a, b)
    numbers.push(result)
  }

  return numbers[0]
}

const result = fs
  .readFileSync(argv[2], { encoding: 'utf8', flag: 'r' })
  .trimEnd()
  .split('\n')
  .map(evaluateExpression)
  .reduce((sum, value) => sum + value, 0)

console.log(`Solution: ${result}`)
