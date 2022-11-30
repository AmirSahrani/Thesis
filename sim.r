simpel_sim <- rbinom(100000, 1, 0.51)
mean(simpel_sim)
x <- 1
succes <- c()
means <- c()
# for (y in 1:10000){
# for (i in 1:100000){
#     if (x == 1){
#         x2 <- rbinom(1, 1, 0.50)
#         if (x == x2){
#             succes[i] <- 1
#             x <- x2
#         } else {
#             succes[i] <- 0
#             x <- x2
#         }
#     }else{
#         x2 <- rbinom(1, 1, 0.50)
#         if (x == x2){
#             succes[i] <- 1
#             x <- x2
#         } else {
#             succes[i] <- 0
#             x <- x2
#             }
#         }
#     }
#     means[y] <- mean(succes)
#     print(y)
# }
str <- ""
outcome <- "h"
for (i in 1:100) {
    if (outcome == "h") {
        x <- rbinom(1, 1, 0.51)
        outcome <- ifelse(x == 1, "h", "t")
        str <- paste(str, outcome, sep = "")
    } else {
        x <- rbinom(1, 1, 0.49)
        outcome <- ifelse(x == 1, "h", "t")
        str <- paste(str, outcome, sep = "")
    }
}

split_outcome <- strsplit(str, split = "")
length(split_outcome)
split_decoded <- c()
for (i in 1:length(split_outcome)) {
    if (split_outcome[i] == "h") {
        split_decoded[i] <- 1
    } else {
        split_decoded[i] <- 0
    }
}
split_decoded
# [0.5, 0.5, 0.501, 0.501, 0.501, 0.501, 0.501, 0.501, 0.501, 0.502, 0.502, 0.502, 0.503, 0.503, 0.503, 0.503, 0.503, 0.504, 0.5055, 0.5055, 0.5055, 0.513, 0.523, 0.529, 0.533, 0.534] # nolint
# x = c(0.5, 0.5, 0.501, 0.501, 0.501, 0.501, 0.501, 0.501, 0.501, 0.502, 0.502, 0.502, 0.503, 0.503, 0.503, 0.503, 0.503, 0.504, 0.5055, 0.5055, 0.5055, 0.513, 0.523, 0.529, 0.533, 0.534,0.545) # nolint
# mean(x[1:26])
# median(x)
# length(x)
library("EnvStats")
x <- seq(0, 1, 0.001)
null_data <- matrix(data = NA, nrow = 6*150, ncol = 2) #nolint
alt_data <- matrix(data = NA, nrow = 6*150, ncol = 2) #nolint
alt_person_data <- matrix(data = NA, nrow = 6*150, ncol = 2) #nolint
colnames(null_data) <- c("Person", "Mean of trail")
colnames(alt_data) <- c("Person", "Mean of trail")
colnames(alt_person_data) <-= c("Person", "Mean of trail")

null_means <- c()
alt_means <- c()
alt_person_means <- c()
start <- Sys.time()
Prior_Mean <- rnormTrunc(n = 1, mean = 0.50694, sd = 0.0125, min = 0.5, max = 1) # nolint
starting <- 0
for (i in 1:6) {
    person_error <- rnorm(1, mean = 0, sd = 0.01)
    for (j in 1:150) {
        starting <- starting + 1
        trail <- rbinom(100, 1, 0.50)
        trail_alt <- rbinom(100, 1, Prior_Mean)
        trail_altperson <- rbinom(100, 1, Prior_Mean + person_error)
        null_data[starting, 2] <- mean(trail)
        null_data[starting, 1] <- i
        alt_data[starting, 2] <- mean(trail_alt)
        alt_data[starting, 1] <- i
        alt_person_data[starting, 2] <- mean(trail_altperson)
        alt_person_data[starting, 1] <- i
    }
}

mean(null_data[,2])
mean(alt_data[,2])
mean(alt_person_data[,2])
# hist_1 <- hist(null_means) # nolint
# hist_2 <- hist(alt_means) # nolint
# hist_3 <- hist(alt_person_means) # nolint
# plot(hist_1, col = "red", xlim = c(0.4, 0.6)) # nolint
# plot(hist_2, add = T, col = "blue") # nolint
# plot(hist_3, add = T, col = "green") # nolint
# end <- Sys.time() # nolint
# runtime <- end - start # nolint
# print(runtime) # nolint

prior <- dnormTrunc(x, mean = 0.50694, sd = 0.0125, min = 0.5, max = 1)
plot(x, prior, type = "l", ylab = "Desnity", xlab = "Proportion of succeses", main = "Prior", lwd = 2, col = "red", xlim = c(0.49, 0.51)) # nolint
abline(v = 0.5)
legend("topright", legend = c("Alternative hypothesis", "Null hypothesis"), lty = c(1, 1), col = c("red", "black")) # nolint

