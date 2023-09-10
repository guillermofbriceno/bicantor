## Bicantor Core

7-stage, dual-issue pipeline with branch prediction implementing RV32I.

This core was a challenge in implementing more advanced microarchitectural principles compared to my previous cores. While the core does work, in the future, I will focus on implementing a real-world feature set rather than the primitive rv32i extension set with high-performance features.

### Architecture

The branch prediction engine uses a branch-target-buffer and G-share direction predictor. Only the first issue can process branches. In the fetch stage, two instructions are read simultaneously, moving on to decode and issue stages which will resolve issue-based dependencies by swapping or halting one of the issue pipelines for a single cycle. Execution includes full bypassing for both issues, and the core requires a quad-read, dual-write register file.

![Prototype Logisim Model](https://github.com/guillermofbriceno/bicantor/blob/main/docs/design_notes/core_prototype_model.png?raw=true)

### Tests
There are two test systems used, pre-synthesis quicktests found in `tests/quicktests` and formal verification using `riscv-formal`. Quicktests are hand-made for sanity checking during development, ensuring the execution flow remains relatively sound. 

#### RISC-V Formal
RISC-V formal tests take a few hours to run depending on depth. The `checks.cfg` is set to prove mode with an `nret` of 2, and a `depth` of 20. A sample output of a successful run on the `and` instruction on channel `0`:
```
SBY  0:36:05 [insn_and_ch1] engine_0.basecase: ##   0:00:00  Checking assumptions in step 20..
SBY  0:36:05 [insn_and_ch1] engine_0.induction: ##   0:00:00  Trying induction in step 1..
SBY  0:36:08 [insn_and_ch1] engine_0.induction: ##   0:00:04  Temporal induction successful.
SBY  0:36:08 [insn_and_ch1] engine_0.induction: ##   0:00:04  Status: passed
SBY  0:36:08 [insn_and_ch1] engine_0.induction: finished (returncode=0)
SBY  0:36:08 [insn_and_ch1] engine_0: Status returned by engine for induction: pass
SBY  0:36:20 [insn_and_ch1] engine_0.basecase: ##   0:00:15  Checking assertions in step 20..
SBY  0:36:26 [insn_and_ch1] engine_0.basecase: ##   0:00:21  Status: passed
SBY  0:36:26 [insn_and_ch1] engine_0.basecase: finished (returncode=0)
SBY  0:36:26 [insn_and_ch1] engine_0: Status returned by engine for basecase: pass
SBY  0:36:26 [insn_and_ch1] summary: Elapsed clock time [H:MM:SS (secs)]: 0:00:24 (24)
SBY  0:36:26 [insn_and_ch1] summary: Elapsed process time [H:MM:SS (secs)]: 0:00:28 (28)
SBY  0:36:26 [insn_and_ch1] summary: engine_0 (smtbmc boolector) returned pass for induction
SBY  0:36:26 [insn_and_ch1] summary: engine_0 (smtbmc boolector) returned pass for basecase
SBY  0:36:26 [insn_and_ch1] summary: successful proof by k-induction.
SBY  0:36:26 [insn_and_ch1] DONE (PASS, rc=0)
```
