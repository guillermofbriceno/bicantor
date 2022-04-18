import os

TESTDIR = "./tests/quicktests"
BUILDDIR = "./build"
UTILDIR = "./util"

testnames = [ 
        "bypass",
        "br-simple-conditional",
        "br-prediction-torture"
]

testcycles= [
        10,
        23,
        122
]

results = []
    
def main():
    print("\n----------------------------------------")
    print("Running Quicktests\n")
    print("Test" + " "*27 + "Status")
    for test, cycles in zip(testnames, testcycles):
        print(f"{test:<30} ", end="")
        oracleregs = []
        testregs = []
        os.system(f"vvp {BUILDDIR}/uut.vvp +TEST={BUILDDIR}/{test} +CYCLES={cycles} > /dev/null")

        with open (f"{BUILDDIR}/finalregs") as f: oracleregs = [l for l in f]
        with open (f"{TESTDIR}/{test}.regs") as f: testregs = [l for l in f]

        results.append(not oracleregs == testregs)
        if oracleregs == testregs:
            print("PASS")
        else:
            print("*FAIL*")

    print("\nQuicktests ", end="")
    if any(results):
        print("*FAILED*")
    else:
        print("PASSED")

    print("----------------------------------------\n")

main()

