import math
import sys

parameters = {
    "P": 115792089210356248762697446949407573530086143415290314195533631308867097853951,
    "N": 115792089210356248762697446949407573529996955224135760342422259061068512044369,
    "A": 115792089210356248762697446949407573530086143415290314195533631308867097853948,
    "B": 41058363725152142129326129780047268409114441015993725554835256314039467401291,
    "Gx": 48439561293906451759052585252797914202762949526041747995844080717082404635286,
    "Gy": 36134250956749795798585127919587881956611106672985015071877198253568414405109,
}


def get_long(n, k, x):
    ret = []
    for idx in range(k):
        ret.append(x % (2 ** n))
        x = x // (2 ** n)
    return ret


def get_all_parameters_long():
    return_string = ""

    nk_pairs = [(86, 3), (64, 4)]
    for (n, k) in nk_pairs:
        for param in parameters:
            return_string += param + " = " + \
                str(get_long(n, k, parameters[param])) + "\n"

    return return_string


orig_stdout = sys.stdout
f = open('../script_outputs/p256_params_long.circom', 'w')
sys.stdout = f

print(get_all_parameters_long())
