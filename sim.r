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
for (i in 1:100){
    if (outcome == "h"){
    x <- rbinom(1,1,0.51)
    outcome <- ifelse(x == 1, "h", "t")
    str = paste(str,outcome, sep = "")
    }else{
    x <- rbinom(1,1,0.49)
    outcome <- ifelse(x == 1, "h", "t")
    str = paste(str,outcome, sep = "")
    }
}

split_outcome <- strsplit(str, split="")
split_decoded <- ifelse(split_outcome == "h",1,0)
split_decoded