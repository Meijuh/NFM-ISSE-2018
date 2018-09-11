#!/usr/bin/Rscript

library(data.table)
library(ggplot2)
library(tidyr)
library(grid)
library(gridExtra)

# load all the data in the directory given by the first program argument
args <- commandArgs(trailingOnly = TRUE) 
files <- dir(args[1], full.names = TRUE, pattern="*.csv") 
df <- do.call(rbind, lapply(files, read.csv))
dt <- as.data.table(df, keep.rownames = TRUE)

# all column names that contain query numbers
query_types <- c("realqueries", "learnqueries", "eqqueries", "emqueries", "emoqueries", "inqueries")

# identify all problem instances
problems <- unique(dt$problem)

# identify all automaton types
auts <- unique(dt$aut)

# identify all black-box oracles
bbos <- unique(dt$bbo)

# aux. function to plot legends separately
g_legend <-function(a.gplot) {
	tmp <- ggplot_gtable(ggplot_build(a.gplot))
	leg <- which(sapply(tmp$grobs, function(x) x$name) == "guide-box")
	legend <- tmp$grobs[[leg]]
	legend
}

# order the data
dt <- dt[order(problem, learner, aut, learnqueries, bbo)]
dt[, falsified := 1:.N, by=list(learner, problem, aut, bbo)]

# labels for aut
aut_breaks <- c("monitor", "buchi", "monitor-buchi")
aut_labels <- c("Monitor", "Büchi", "Monitor & Büchi")
aut_map <- setNames(as.list(aut_labels), aut_breaks)

learner_breaks <- c("ADT", "DHC", "DiscriminationTree", "ExtensibleLStar", "KearnsVazirani", "MalerPnueli", "RivestSchapire", "TTT")
learner_labels <- c("ADT", "DHC", "Discrimination Tree", "L*", "Kearns & Vazirani", "Maler & Pnueli", "Rivest & Schapire", "TTT")

bbo_breaks <- c("cex-first", "disprove-first", "none")
bbo_labels <- c("CExFirstOracle", "DisproveFirstOracle", "None")

# plot number of falsified formulae per problem instance and automaton type
for (p in problems) {
    for (a in auts) {
        problem_dt <- subset(dt, dt$problem == p & dt$aut == a)

        # plot for each query type
        for (query_type in query_types) {
            max <- max(problem_dt[[query_type]])
            if (max > 0) {
                pdf(paste("falsified", query_type, p, a, ".pdf", sep = "-")
                    , height=3, width=6
                    , title = paste("falsified", query_type, p, a, sep=" - "))

                graph <- ggplot(data=problem_dt, aes(x=problem_dt[[query_type]], y=falsified, colour=learner)) +
                    #ggtitle(paste("#falsified formulae, problem: ", p, ", automaton: ", a, sep = "")) +
                    geom_line(aes(linetype=bbo)) +
                    labs(y = "#falsified", x = "#queries", colour = "Learner", linetype = "Black-box oracle") +
                    scale_x_log10() +
                    theme_light() +
                    theme(legend.position="none") +
                    scale_color_discrete(breaks=learner_breaks, labels=learner_labels) +
                    scale_linetype_discrete(breaks=bbo_breaks, labels=bbo_labels)

                print(graph)
                dev.off()

                # print legend
                pdf(paste("legend-falsified", query_type, p, a, ".pdf", sep = "-"),
                    height=1, title="Legend", onefile=FALSE, width=5.5)
                legend <- graph +
                    theme(legend.position=c(.5,.5), legend.direction="horizontal", legend.margin=margin(-2,-2,-2,2))
                legend <- g_legend(legend)
                grid.arrange(legend)
                dev.off()
            }

            # plot for size of hypothesis
            max <- max(problem_dt$size)
            if (max > 0) {
                pdf(paste("falsified", "size", p, a, ".pdf", sep = "-")
                    , height=3, width=6
                    , title = paste("falsified", "size", p, a, sep=" - "))

                graph <- ggplot(data=problem_dt, aes(x=problem_dt$size, y=falsified, colour=learner)) +
                    #ggtitle(paste("#falsified formulae, problem: ", p, ", automaton: ", a, sep = "")) +
                    geom_line(aes(linetype=bbo)) +
                    labs(y = "#falsified", x = "#states", colour = "Learner", linetype = "Black-box oracle") +
                    theme_light() +
                    theme(legend.position="none") +
                    scale_color_discrete(breaks=learner_breaks, labels=learner_labels) +
                    scale_linetype_discrete(breaks=bbo_breaks, labels=bbo_labels)

                print(graph)
                dev.off()

                # print legend
                pdf(paste("legend-falsified", "size", p, a, ".pdf", sep = "-"),
                    height=1, title="Legend", onefile=FALSE, width=5.5)
                legend <- graph +
                    theme(legend.position=c(.5,.5), legend.direction="horizontal", legend.margin=margin(-2,-2,-2,2))
                legend <- g_legend(legend)
                grid.arrange(legend)
                dev.off()
            }

            # plot for refinements
            max <- max(problem_dt$refinements)
            if (max > 0) {
                pdf(paste("falsified", "refinements", p, a, ".pdf", sep = "-")
                    , height=3, width=6
                    , title = paste("falsified", "refinements", p, a, sep=" - "))

                graph <- ggplot(data=problem_dt, aes(x=problem_dt$refinements, y=falsified, colour=learner)) +
                    #ggtitle(paste("#falsified formulae, problem: ", p, ", automaton: ", a, sep = "")) +
                    geom_line(aes(linetype=bbo)) +
                    labs(y = "#falsified", x = "#hypothesis refinements", colour = "Learner", linetype = "Black-box oracle") +
                    scale_x_log10() +
                    theme_light() +
                    theme(legend.position="none") +
                    scale_color_discrete(breaks=learner_breaks, labels=learner_labels) +
                    scale_linetype_discrete(breaks=bbo_breaks, labels=bbo_labels)

                print(graph)
                dev.off()

                # print legend
                pdf(paste("legend-falsified", "refinements", p, a, ".pdf", sep = "-"),
                    height=1, title="Legend", onefile=FALSE, width=5.5)
                legend <- graph +
                    theme(legend.position=c(.5,.5), legend.direction="horizontal", legend.margin=margin(-2,-2,-2,2))
                legend <- g_legend(legend)
                grid.arrange(legend)
                dev.off()
            }
        }
    }
}

# plot number of falsified formulae per problem instance and bbo
for (p in problems) {
    for (b in bbos) {
        problem_dt <- subset(dt, dt$problem == p & dt$bbo == b)

        # plot for each query type
        for (query_type in query_types) {
            max <- max(problem_dt[[query_type]])
            if (max > 0) {
                pdf(paste("falsified", query_type, p, b, ".pdf", sep = "-")
                    , height=3, width=6
                    , title = paste("falsified", query_type, p, b, sep=" - "))

                graph <- ggplot(data=problem_dt, aes(x=problem_dt[[query_type]], y=falsified, colour=learner)) +
                    #ggtitle(paste("#falsified formulae, problem: ", p, ", black-box oracle: ", b, sep = "")) +
                    geom_line(aes(linetype=aut)) +
                    labs(y = "#falsified", x = "#queries", colour = "Learner", linetype = "Automaton") +
                    scale_x_log10() +
                    theme_light() +
                    theme(legend.position="none") +
                    scale_color_discrete(breaks=learner_breaks, labels=learner_labels) +
                    scale_linetype_discrete(breaks=aut_breaks, labels=aut_labels)

                print(graph)
                dev.off()

                # print legend
                pdf(paste("legend-falsified", query_type, p, b, ".pdf", sep = "-"),
                    height=1, title="Legend", onefile=FALSE, width=5.5)
                legend <- graph +
                    theme(legend.position=c(.5,.5), legend.direction="horizontal", legend.margin=margin(-2,-2,-2,2))
                legend <- g_legend(legend)
                grid.arrange(legend)
                dev.off()
            }

            # plot for size of hypothesis
            max <- max(problem_dt$size)
            if (max > 0) {
                pdf(paste("falsified", "size", p, b, ".pdf", sep = "-")
                    , height=3, width=6
                    , title = paste("falsified", "size", p, b, sep=" - "))

                graph <- ggplot(data=problem_dt, aes(x=problem_dt$size, y=falsified, colour=learner)) +
                    #ggtitle(paste("#falsified formulae, problem: ", p, ", black-box oracle: ", b, sep = "")) +
                    geom_line(aes(linetype=aut)) +
                    labs(y = "#falsified", x = "#states", colour = "Learner", linetype = "Automaton") +
                    theme_light() +
                    theme(legend.position="none") +
                    scale_color_discrete(breaks=learner_breaks, labels=learner_labels) +
                    scale_linetype_discrete(breaks=aut_breaks, labels=aut_labels)

                print(graph)
                dev.off()

                # print legend
                pdf(paste("legend-falsified", "size", p, b, ".pdf", sep = "-"),
                    height=1, title="Legend", onefile=FALSE, width=5.5)
                legend <- graph +
                    theme(legend.position=c(.5,.5), legend.direction="horizontal", legend.margin=margin(-2,-2,-2,2))
                legend <- g_legend(legend)
                grid.arrange(legend)
                dev.off()
            }

            # plot for refinements
            max <- max(problem_dt$refinements)
            if (max > 0) {
                pdf(paste("falsified", "refinements", p, b, ".pdf", sep = "-")
                    , height=3, width=6
                    , title = paste("falsified", "refinements", p, b, sep=" - "))

                graph <- ggplot(data=problem_dt, aes(x=problem_dt$refinements, y=falsified, colour=learner)) +
                    #ggtitle(paste("#falsified formulae, problem: ", p, ", black-box oracle: ", b, sep = "")) +
                    geom_line(aes(linetype=aut)) +
                    labs(y = "#falsified", x = "#hypothesis refinements", colour = "Learner", linetype = "Automaton") +
                    theme_light() +
                    scale_x_log10() +
                    theme(legend.position="none") +
                    scale_color_discrete(breaks=learner_breaks, labels=learner_labels) +
                    scale_linetype_discrete(breaks=aut_breaks, labels=aut_labels)

                print(graph)
                dev.off()

                # print legend
                pdf(paste("legend-falsified", "refinements", p, b, ".pdf", sep = "-"),
                    height=1, title="Legend", onefile=FALSE, width=5.5)
                legend <- graph +
                    theme(legend.position=c(.5,.5), legend.direction="horizontal", legend.margin=margin(-2,-2,-2,2))
                legend <- g_legend(legend)
                grid.arrange(legend)
                dev.off()
            }
        }
    }
}


# plot lengths of counterexamples for the ADT and disprove-first algorithm
for (p in problems) {
    for (l in auts) {
        for (r in auts) {
            if (l != r) {
                left_dt <- subset(dt, dt$problem == p & dt$aut == l
                                  & dt$learner == "ADT" & dt$bbo == "disprove-first"
                                  )
                right_dt <- subset(dt, dt$problem == p & dt$aut == r
                                   & dt$learner == "ADT" & dt$bbo == "disprove-first"
                                   )

                if (nrow(left_dt) > 0 & nrow(right_dt) > 0) {

                    problem_dt <- merge(left_dt, right_dt, by=c("learner","bbo","property")
                                        , all = TRUE
                                        )

                    problem_dt$length.x[is.na(problem_dt$length.x)] <- -1
                    problem_dt$length.y[is.na(problem_dt$length.y)] <- -1


                    pdf(paste("length", p, l, r, ".pdf", sep = "-")
                        , height=4, width=4
                        , title = paste("length", p, l, r, sep = "-"))

                    graph <- ggplot(problem_dt, aes(x=length.x, y=length.y
                                                    #, colour=learner
                                                    )) +
                        #ggtitle(paste("Length of counterexamples, learner: ADT, bbo: disprove-first, problem: ", p, sep = "")) +
                        geom_point(
                                   #aes(shape=bbo)
                                   ) +
                        stat_function(fun=function(x)x, geom="line", linetype="dotted") +
                        geom_hline(yintercept=0) +
                        geom_vline(xintercept=0) +
                        labs(x = aut_map[[l]], y = aut_map[[r]], colour = "Learner"
                             #, shape = "Black-box oracle"
                             ) +
                        theme_light()

                        #if (r == "Büchi") {
                        #    graph <- graph +
                        #        scale_y_log10() +
                        #        scale_x_continuous(limits = c(-1, max(problem_dt$length.x)))
                        #} else {
                        #    graph <- graph +
                        #        scale_x_log10() +
                        #        scale_y_continuous(limits = c(-1, max(problem_dt$length.y)))
                        #}

                    print(graph)
                    dev.off()
                }
            }
        }
    }
}

