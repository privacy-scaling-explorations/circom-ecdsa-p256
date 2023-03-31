import math
import sys
import compute_p256_math

P = 2**256 - 2**224 + 2**192 + 2**96 - 1

return_str = ""

for m in {7, 10}:
    return_str += str(m) + " reduce: \n"
    for i in range(m):
        raw_coeff = 2**(64*i) % P
        return_str += "init coeff of a" + \
            str(i) + " = " + str(compute_p256_math.get_long(64, 4, raw_coeff)) + "\n"
    return_str += "\n"


orig_stdout = sys.stdout
f = open('../script_outputs/register_reduce_out.txt', 'w')
sys.stdout = f

print(return_str)
