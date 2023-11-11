import path = require("path");

import { expect, assert } from 'chai';
import { getPublicKey, Point } from '@noble/secp256k1';
const circom_tester = require('circom_tester');
const wasm_tester = circom_tester.wasm;

const F1Field = require("ffjavascript").F1Field;
const Scalar = require("ffjavascript").Scalar;
exports.p = Scalar.fromString("21888242871839275222246405745257275088548364400416034343698204186575808495617");
const Fr = new F1Field(exports.p);

const p = 0xffffffff00000001000000000000000000000000ffffffffffffffffffffffffn;
const g_x = 0x6b17d1f2e12c4247f8bce6e563a440f277037d812deb33a0f4a13945d898c296n;
const g_y = 0x4fe342e2fe1a7f9b8ee7eb4a7c0f9e162bce33576b315ececbb6406837bf51f5n

function bigint_to_array(n: number, k: number, x: bigint) {
  let mod: bigint = 1n;
  mod = 2n**BigInt(n);

  let ret: bigint[] = [];
  var x_temp: bigint = x;
  for (var idx = 0; idx < k; idx++) {
      ret.push(x_temp % mod);
      x_temp = x_temp / mod;
  }
  return ret;
}

function evaluate(x: bigint[], n: bigint) {
  let total = 0n
  let i = 0n
  let base = 2n**n;
  for (let t of x) {
    total += t*(base**i)
    i += 1n
  }
  return total
}

describe("Reduction", function () {
  this.timeout(1000 * 1000);

  let circuit: any;
  let reduce_circuit_7: any;
  let reduce_circuit_10: any;
  before(async function () {
      circuit = await wasm_tester(path.join(__dirname, "circuits_p256", "test_reduction.circom"));
      reduce_circuit_7 = await wasm_tester(path.join(__dirname, "circuits_p256", "test_primereduce_7.circom"));
      reduce_circuit_10 = await wasm_tester(path.join(__dirname, "circuits_p256", "test_primereduce_10.circom"));
  });

  it('PrimeReduce7Registers', async () => {
    let test_reduction = async (input: bigint[]) => {
      console.log(evaluate(input, 64n));
      let witness = await reduce_circuit_7.calculateWitness({"in": input});
      let output = witness.slice(1,5);
      assert(evaluate(input, 64n) % p == evaluate(output, 64n) % p);
    }

    let overflowed_registers = [1n, 2n**70n-1n, 2n**50n, 0n, 2n**150n, 0n, 0n];
    await test_reduction(overflowed_registers);

  });

  it('PrimeReduce10Registers', async () => {
    let test_reduction = async (input: bigint[]) => {
      console.log(evaluate(input, 64n));
      let witness = await reduce_circuit_10.calculateWitness({"in": input});
      let output = witness.slice(1,9);
      assert(evaluate(input, 64n) % p == evaluate(output, 32n) % p);
    }

    let overflowed_registers = [1n, 2n**70n-1n, 2n**50n, 0n, 2n**40n, 0n, 2n**160n-1n, 0n, 2n**200n, 0n];
    await test_reduction(overflowed_registers);
  });
});