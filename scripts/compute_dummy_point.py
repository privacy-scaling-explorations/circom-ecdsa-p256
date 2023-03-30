import compute_p256_math
import math
import sys

tmpGx = compute_p256_math.Gx
tmpGy = compute_p256_math.Gy
for i in range(255):
    tmpGx, tmpGy = compute_p256_math.double(tmpGx, tmpGy)

Gx_255 = tmpGx
Gy_255 = tmpGy

return_str = ""
for (n,k) in {(64,4), (86,3)}:
    return_str += "(n,k) = " + str((n,k)) + "\n"
    Gx_255_long = compute_p256_math.get_long(n, k, Gx_255)
    Gy_255_long = compute_p256_math.get_long(n, k, Gy_255)
    return_str += "2^255 * Gx = " + str(Gx_255_long) + "\n"
    return_str += "2^255 * Gy = " + str(Gy_255_long) + "\n"
    return_str += "\n"

orig_stdout = sys.stdout
f = open('../script_outputs/dummy_point_out.circom', 'w')
sys.stdout = f

print(return_str)





