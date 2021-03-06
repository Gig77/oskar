# Assumes you've already run coverageBed -hist, and grep'd '^all'. E.g. something like:
# find *.bam | parallel 'bedtools -abam {} -b capture.bed -hist | grep ^all > {}.all.txt'

maxdepth <- 100

# Get a list of the bedtools output files you'd like to read in
files <- list.files(path="/mnt/projects/oskar/results/coverage", pattern=".coverage.bedtools.txt$")
labs <- sapply(strsplit(files, "variant_calling_process_sample_", fixed=T), "[[", 1); labs <- sapply(strsplit(labs, ".", fixed=T), "[[", 1) # extract sample name from file name
 # extract sample name from file name

# Create lists to hold coverage and cumulative coverage for each alignment,
# and read the data into these lists.
cov <- list()
cov_cumul <- list()
means <- numeric(0)
for (i in 1:length(files)) {
	cov[[i]] <- read.table(paste0("/mnt/projects/oskar/results/coverage/", files[i]))
	cov_cumul[[i]] <- 1-cumsum(cov[[i]][,5])
	means[i] <- cov_cumul[[i]][50]
}

# Pick some colors
# Ugly:
# cols <- 1:length(cov)
# Prettier:
# ?colorRampPalette
# display.brewer.all()
library(RColorBrewer)
#cols <- brewer.pal(length(cov), "Dark2")
cols <- rainbow(length(cov))
ltypes <- rep(1:6,length.out=length(cov))

# Save the graph to a file
png("/mnt/projects/oskar/results/coverage/coverage.png.part", h=2000, w=2700, pointsize=40)

# Create plot area, but do not plot anything. Add gridlines and axis labels.
layout(matrix(c(1,2), nrow = 1), widths = c(0.8, 0.2))

par()
plot(cov[[1]][2:(maxdepth+1), 2], cov_cumul[[1]][1:maxdepth], type='n', xlab="Coverage", ylab="Percentage of target bases \u2265 coverage", ylim=c(0,1.0), main="Exome Sequencing Unique Coverage", xaxt="n", yaxt="n")
abline(v = c(0, 5, 10, 20, 30, 50, 100), col = "gray60", lty=3)
abline(h = seq(0, 1, 0.1), col = "gray60", lty=3)
abline(h = 0.5, col = "gray60", lty=1)
axis(1, at=c(0, 5, 10, 20, 30, 50, 100))
axis(2, at=seq(0, 1, 0.1))

# Actually plot the data for each of the alignments (stored in the lists).
for (i in 1:length(cov)) points(cov[[i]][2:(maxdepth+1), 2], cov_cumul[[i]][1:maxdepth], type='l', lwd=3, lty=ltypes[i], col=cols[i])

# Add a legend using the nice sample labeles rather than the full filenames.
par(mar=c(0, 0, 6, 0), cex=0.7)
plot(0:1, 0:1, type="n", axes=F, ann=F)
legend("topleft", legend=labs[order(means, decreasing=T)], col=cols[order(means, decreasing=T)], lwd=3, lty=ltypes[order(means, decreasing=T)], ncol=1)

dev.off()