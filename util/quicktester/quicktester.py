import os

TESTDIR = "./tests/quicktests"
BUILDDIR = "./build"
UTILDIR = "./util"

testnames = [ "branch", "bypass"]
testcycles= [       22,     10 ]

results = []
    
def main():
    for test, cycles in zip(testnames, testcycles):
        print(f"Test {test}: ", end="")
        oracleregs = []
        testregs = []
        os.system(f"vvp {BUILDDIR}/uut.vvp +TEST={BUILDDIR}/{test} +CYCLES={cycles} > /dev/null")

        with open (f"{BUILDDIR}/finalregs") as f: oracleregs = [l for l in f]
        with open (f"{TESTDIR}/{test}.regs") as f: testregs = [l for l in f]

        results.append(not oracleregs == testregs)
        if oracleregs == testregs:
            print("PASS")
        else:
            print("FAIL")

    print("\nQuicktests ", end="")
    if any(results):
        print("FAILED\n")
    else:
        print("PASSED\n")

main()

