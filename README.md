# Sound Black-Box Checking in the LearnLib

This README first explains how to install several Maven projects, and LTSmin required to run the benchmarks.
Next it will explain where to find all data and re-analyze the data.

Note that this repository is for data for the extended ISSE version of "Sound Black-Box Checking in the LearnLib".
To find the data for the NFM 2018 proceedings version, look here: https://github.com/Meijuh/NFM2018BBC.

## Compiling

To reproduce our benchmarks it is required to install four Maven projects and to download LTSmin.

1. A new version of the AutomataLib: https://github.com/Meijuh/automatalib/releases/tag/NFM-ISSE-2018.
1. A new version of the LearnLib: https://github.com/Meijuh/learnlib/releases/tag/NFM-ISSE-2018.
1. Our modified RERS 2017 Problems: https://github.com/Meijuh/RERS2017-seq-problems/releases/tag/NFM2018.
1. Our SUL implementation for the RERS 2017 problems: https://github.com/Meijuh/RERS2017/releases/tag/NFM-ISSE-2018.

All Maven projects should be installed in above order with `mvn install`.
However it may be the case that for https://github.com/Meijuh/RERS2017-seq-problems the java compiler runs out of memory.
This can be resolved by using e.g. `export MAVEN_OPTS="-Xmx13g -Xms10g"`.

LTSmin should be downloaded here: https://github.com/Meijuh/ltsmin/releases/tag/NFM-ISSE-2018.
One can download and compile the sources, or immediately download the pre-compiled binaries.
**Make sure the LTSmin binaries are in the `PATH` variable**.

The Maven project of the SUL implementation at https://github.com/Meijuh/RERS2017 also contains an extra target `mvn compile assembly:single`.
This is convienient for creating a jar file that contains all dependencies.
Once this jar file is built, run `java -cp target/RERS-1.0-SNAPSHOT-jar-with-dependencies.jar nl.utwente.fmt.rers.Main`.
This should output usage information:

    [main] INFO nl.utwente.fmt.rers.Main - hostname: jeroen-laptop
    [main] INFO nl.utwente.fmt.rers.Main - commandline is:
    usage: java nl.utwente.fmt.rers.Main [problem number] [learner] [-a] [-B]
           [-C] [-c] [-D] [-h] [-m <arg>] [-M] [-r] [-s] [-t <arg>] [-u <arg>]
    You can apply both the option --monitor, and --buchi, then first monitors
    will be used disprove properties. You have to supply at least one of
    --monitor and --buchi. Also, you have to choose between --disprove-first,
    and --cex-first, but they are mutually exclusive.
     -a,--no-alternate                do not use alternating edge semantics
     -B,--buchi                       create a Büchi automaton
     -C,--cex-first                   use counter example first black-box
                                      oracle
     -c,--cache                       use a model checker cache
     -D,--disprove-first              use disprove first black-box oracle
     -h,--help                        prints help
     -m,--multiplier <arg>            multiplier for unrolls
     -M,--monitor                     create a Monitor
     -r,--no-random-words             do not use an additional random words
                                      equivalence oracle
     -s,--ltsmin-skip-version-check   skip the LTSmin version check
     -t,--timeout <arg>               timeout in seconds
     -u,--minimum-unfolds <arg>       minimum number of unfolds
    
    Created by Jeroen Meijer

Mandatory parameters are `problem number` indicating the RERS problem number, which ranges from 1-9, and the `learner` which should be any of `{ADT, DHC, DiscriminationTree, KearnsVazirani, ExtensibleLStar, MalerPnueli, RivestSchapire, TTT}`.
A mandatory flag is `--ltsmin-skip-version-check`.
Note that supplying at least one of `--monitor` and `--buchi` is also necessary.
Supplying `--monitor` will perform black-box checking with *monitoring*, and supplying `--buchi` will perform black-box checking with *model checking*.
One can also give both `--monitor` *and* `--buchi*.
If both flags are given then *first* monitors are used to disprove properties and hypotheses before Büchi automata are used.

So running `java -cp target/RERS-1.0-SNAPSHOT-jar-with-dependencies.jar nl.utwente.fmt.rers.Main 1 TTT -B` performs black-box checking with *model checking*.
On standard output one can find CSV output of properties falsified, and on standard error logging information can be found.

The CSV columns are as follows:

* problem: the problem number,
* learner: the learning algorithm,
* aut: the automaton type used, i.e. Büchi, monitor, or Büchi *and* monitor.
* bbo: the black-box oracle used, i.e. CExFirstOracle, DisproveFirstOracle, or -- none --.
* property: the property number falsified,
* size: the size of the hypothesis used to disprove the property,
* realsymbols: the accumulative number of symbols by all oracles used to disprove the property,
* learnsymbols: the accumulative number of symbols the learner used to disprove the property,
* eqsymbols: the accumulative number of symbols the equivalence oracle used to disprove the property,
* emsymbols: the accumulative number of symbols the emptiness oracle used to disprove the property,
* emosymbols: the accumulative number of symbols the lasso emptiness oracle used to disprove the property,
* insymbols: the accumulative number of symbols the inclusion oracle used to disprove the property,
* realqueries: the accumulative number of queries by all oracles used to disprove the property,
* learnqueries: the accumulative number of queries the learner used to disprove the property,
* eqqueries: the accumulative number of queries the equivalence oracle used to disprove the property,
* emqueries: the accumulative number of queries the emptiness oracle used to disprove the property,
* emoqueries: the accumulative number of queries the lasso emptiness oracle used to disprove the property,
* inqueries: the accumulative number of queries the inclusion oracle used to disprove the property,
* length: the length of the counterexample that disproves the property,
* multiplier: the multiplier used to determine the number of unrolls of the lasso,
* refinements: the number of hypothesis refinements to disprove the property.

On standard error the following logging error can be found:

1. first all LTL formulae are printed,
1. spurious counterexamples used to refine the hypotheses,
1. queries that disprove certain LTL formulae.

## Analyzing data

The graphs from all our experiments can be found in the folder `pdf`.
Files are named as follows:
 * falsified-`query-type`-`n`-`aut`.pdf: these graphs contain the number `query-type` queries on RERS problem instance `n`, with the `aut` automaton type.
 * falsified-size-`n`-`aut`.pdf: these graphs contain the size of the hypothesis on RERS problem instance `n`, with the `aut` automaton type.
 * falsified-refinements-`n`-`aut`.pdf: these graphs contain the the number of hypothesis refinements on RERS problem instance `n`, with the `aut` automaton type.
 * falsified-`query-type`-`n`-`bbo`.pdf: these graphs contain the number `query-type` queries on RERS problem instance `n`, with the `bbo` black-box oracle.
 * falsified-size-`n`-`bbo`.pdf: these graphs contain the size of the hypothesis on RERS problem instance `n`, with the `bbo` black-box oracle.
 * falsified-refinements-`n`-`bbo`.pdf: these graphs contain the the number of hypothesis refinements on RERS problem instance `n`, with the `bbo` black-box oracle.
 * length-`n`-`aut1`-`aut2`.pdf: these graphs contains a scatter plot for lengths of counterexamples with automaton type `aut1` vs. automaton type `aut2` on problem instance `n`.
 * legend-<graph>.pdf: these graphs contain the legend for above graph type `graph`.

All data can be found in folder `csv`.
All files with the extension `.csv` contain the data, and files with extension `.log` contain logging information.

To generate all the graphs manually run `analyze.r csv`.
This will generate all graphs in the present working directory, based on data in the folder `csv`.
Note that to run `analyze.r`, `R` is required with a few dependencies such as `ggplot2`.

