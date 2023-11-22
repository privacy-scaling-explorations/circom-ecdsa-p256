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
const p_circom = 21888242871839275222246405745257275088548364400416034343698204186575808495617n;
const half_p_circom = 10944121435919637611123202872628637544274182200208017171849102093287904247808n;


//const g_x = 0x6b17d1f2e12c4247f8bce6e563a440f277037d812deb33a0f4a13945d898c296n;
//const g_y = 0x4fe342e2fe1a7f9b8ee7eb4a7c0f9e162bce33576b315ececbb6406837bf51f5n

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
    if (t <= half_p_circom) {
      total += t*(base**i)
    } else {
      total -= (p_circom-t)*(base**i)
    }
    i += 1n
  }
  return total
}

describe.only("Reduction", function () {
  this.timeout(1000 * 1000);

  let prime_reduce_circuit: any;
  let reduce_circuit_7: any;
  let reduce_circuit_10: any;
  let proper_circuit_32: any;
  let proper_circuit_64: any;
  let pairing_add: any;
  before(async function () {
      prime_reduce_circuit = await wasm_tester(path.join(__dirname, "circuits_p256", "test_p256_issues.circom"));
      reduce_circuit_7 = await wasm_tester(path.join(__dirname, "circuits_p256", "test_primereduce_7.circom"));
      reduce_circuit_10 = await wasm_tester(path.join(__dirname, "circuits_p256", "test_primereduce_10.circom"));
      proper_circuit_32 = await wasm_tester(path.join(__dirname, "circuits_p256", "test_proper_32.circom"));
      proper_circuit_64 = await wasm_tester(path.join(__dirname, "circuits_p256", "test_proper_64.circom"));
      pairing_add = await wasm_tester(path.join(__dirname, "circuits_p256", "test_pairing_add.circom"));
  });

  it('PrimeReduce7Registers', async () => {
    let test_reduction = async (input: bigint[]) => {
      let witness = await reduce_circuit_7.calculateWitness({"in": input});
      let output = witness.slice(1,5);
      assert(evaluate(input, 64n) % p == evaluate(output, 64n) % p);
    }

    let overflowed_registers = [1n, 2n**70n-1n, 2n**50n, 0n, 2n**150n, 0n, 0n];
    await test_reduction(overflowed_registers);

    let negative_registers = [1n, 2n**70n-1n, 2n**50n, 0n, p_circom-2n**50n, 0n, 0n];
    await test_reduction(negative_registers);
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

    let negative_registers = [1n, 2n**70n, p_circom-2n**100n, 0n, 0n, 0n, 2n**180n, 0n, 2n**10n, 0n];
    await test_reduction(negative_registers);
  });

  it('Working on fix', async () => {
    let x = [4292955422453145964822479413621913075509602355677488716324n,
      14138856352885911993756608258123408875015425226836977408445n,
      19152084246042552967396910108811035673348399945778457592706n,
      12217327447688951856114508225080847269707233820600705128337n,
      1256809376368187748897015378026120801835577723245181144683n,
      21888242871839275216889261160062547566340077405186531670779808987509571599325n,
      21888242871839275216545395842190395868388009954420150990748934327176249927953n,
      21888242871839275220388670537073041598834597465916914078472044975985728502901n,
      923200339955551664594468325804491929844512499798227728984n,
      661957230541661508833462765560680486656693245077732287604n
    ];

    assert(evaluate(x, 64n) % p == 0n);
 
    let witness = await reduce_circuit_10.calculateWitness({"in": x});
    let output = witness.slice(1,9);
    console.log(output);
    assert(evaluate(output, 32n) % p == 0n);

    /*
    let p_8 = [4294967295n, 4294967295n, 4294967295n, 0n, 0n, 0n, 1n, 4294967295n];
    for (let i =0; i < 8; i++) {
      p_8[i] = p_8[i] * (1n << 206n);
    }
    let combined = p_8.map((v, i) => v+output[i]);
    console.log(evaluate(combined, 32n) % p );
    */

    // Given that both the reduced registers and reduced+multipleOfP are correctly 0 mod p,
    // this leads to the proper representation being the issue, as manually taking that mod p is not 0


    // Why does this not work? If we reduce by the prime, then we should get 0...
    // Values in x are > 2^252, which is the max the PrimeReduce circuit can take
    witness = await prime_reduce_circuit.calculateWitness({"in": x});
    output = witness.slice(1,5);
    console.log(output);
    console.log(evaluate(output, 64n) % p);
  });

  it('Test pairing add', async () => {
    // a = (51323763109374747624100439246882351858048138407785253143713149291653816160968,
    //    93836593410645249851930587355592126083379492007445695156684532532430087249995)
    // b = (15158989517374606102125666263834241466554731622775950185683878496736854948661,
    //    96566585871555740846077273591551549731149164699384431564123679057941351907659)
    let a = [bigint_to_array(43, 6, 51323763109374747624100439246882351858048138407785253143713149291653816160968n),
            bigint_to_array(43, 6, 93836593410645249851930587355592126083379492007445695156684532532430087249995n)]
    let b = [bigint_to_array(43, 6, 15158989517374606102125666263834241466554731622775950185683878496736854948661n),
            bigint_to_array(43, 6, 96566585871555740846077273591551549731149164699384431564123679057941351907659n)]
    
    let witness = await pairing_add.calculateWitness({"a": a, "b": b});
    let output = witness.slice(1, 13);

    let c_x = output.slice(0,6);
    let c_y = output.slice(6, 12);

    assert(evaluate(c_x, 43n) == 58697531123994895582260511080010466049175981236279930667057805814208783629959n);
    assert(evaluate(c_y, 43n) ==  92511341067251309075653963355757944451294864382177558832891851970965804116128n);
  });
});