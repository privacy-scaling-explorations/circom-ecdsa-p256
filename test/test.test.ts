import path = require('path');

import { expect, assert } from 'chai';
// import { getPublicKey, Point } from '@noble/secp256k1';
import { P256 } from '@noble/curves/p256';
import { ProjConstructor, ProjPointType } from '@noble/curves/abstract/weierstrass';

function convert(Uint8Arr: Uint8Array): BigInt {
  var length = Uint8Arr.length;
  var result = 0n;
  console.log(typeof result);
  for (var i = 0; i < length; i++) {
    result += BigInt(Uint8Arr[i]) * BigInt(2 ** (8 * i));
  }
  // let buffer = Buffer.from(Uint8Arr);
  // var result = buffer.readUIntBE(0, length);

  return result;
}

var privkeys: Array<bigint> = [
  88549154299169935420064281163296845505587953610183896504176354567359434168161n,
  37706893564732085918706190942542566344879680306879183356840008504374628845468n,
  90388020393783788847120091912026443124559466591761394939671630294477859800601n,
  110977009687373213104962226057480551605828725303063265716157300460694423838923n,
];
var pubkeys: Array<ProjPointType<bigint>> = [];
for (var idx = 0; idx < 4; idx++) {
  var pubkey = P256.ProjectivePoint.fromPrivateKey(privkeys[idx]);
  console.log(pubkey.px);
  pubkeys.push(pubkey);
}

// // const priv = P256.utils.randomPrivateKey();
// const priv = '46c930bc7bb4db7f55da20798697421b98c4175a52c630294d75a84b9c126236';
// console.log(`priv = ${priv}, \n`);
// const pub = P256.getPublicKey(priv);
// console.log(`pub = ${pub}, \n integer version = ${String(convert(pub))}\n`);

// const msg = new Uint8Array(32).fill(1);
// const sig = P256.sign(msg, priv);
// console.log(P256.verify(sig, msg, pub) === true);

// // hex strings are also supported besides Uint8Arrays:
// const privHex = '46c930bc7bb4db7f55da20798697421b98c4175a52c630294d75a84b9c126236';
// const pub2 = P256.getPublicKey(privHex);
