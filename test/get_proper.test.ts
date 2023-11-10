import path = require('path');
import { expect, assert } from 'chai';
import { randomBytes, hexlify } from 'ethers/lib/utils';
const circom_tester = require('circom_tester');
const wasm_tester = circom_tester.wasm;

// TODO: Factor this out into some common code among all the tests
const F1Field = require('ffjavascript').F1Field;
const Scalar = require('ffjavascript').Scalar;
exports.p = Scalar.fromString(
  '21888242871839275222246405745257275088548364400416034343698204186575808495617'
);
const Fr = new F1Field(exports.p);

const p = 0xffffffff00000001000000000000000000000000ffffffffffffffffffffffffn;

function bigint_to_array(n: number, k: number, x: bigint) {
  let mod: bigint = 1n;
  for (var idx = 0; idx < n; idx++) {
    mod = mod * 2n;
  }

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

function get_short(input: Array<number>, n: number) {
  let result = 0;
  for (var i = 0; i < input.length; i++) {
    result += input[i] * 2 ** (n * i);
  }
  return result;
}

function get_random_array(num_bytes: number, k: number): bigint[] {
  let input = [];
  for (let i = 0; i < k; i++) {
    input.push(BigInt(hexlify(randomBytes(num_bytes))));
  }

  return input;
}

describe.only('get proper', function () {
  this.timeout(1000 * 1000);

  // runs circom compilation
  let circuit_32: any;
  let circuit_64: any;
  before(async function () {
    circuit_32 = await wasm_tester(path.join(__dirname, 'circuits_p256', 'test_proper_32.circom'));
    circuit_64 = await wasm_tester(path.join(__dirname, 'circuits_p256', 'test_proper_64.circom'));
  });

  it('getProperRepresentation(240,64,4)', async () => {
    let test_proper = async (input: bigint[]) => {
      let witness = await circuit_64.calculateWitness({"in": input});
      let output = witness.slice(1,9);
      assert(evaluate(input, 64n) == evaluate(output, 64n));
    }

    for (let t = 0; t < 10; t++) {
      await test_proper(get_random_array(30, 4));
    }
  });

  it('getProperRepresentation(234, 32, 8)', async () => {
    let test_proper = async (input: bigint[]) => {
      let witness = await circuit_32.calculateWitness({"in": input});
      let output = witness.slice(1,17);
      assert(evaluate(input, 32n) == evaluate(output, 32n));
    }

    for (let t = 0; t < 10; t++) {
      await test_proper(get_random_array(29, 8));
    }
  });
});
