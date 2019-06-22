library("rstan")

pendulum_data <- read.csv("pend_noisy.csv")
N <- length(pendulum_data$time) - 1
sigma <- c(0.1,0.1);#velocity, theta std
ts <- pendulum_data$time
ts <- ts[2:length(pendulum_data$time)]
y_init <- c(pendulum_data$velocity[1],pendulum_data$theta[1])
y <- as.matrix(pendulum_data[2:(length(pendulum_data$time)),2:3])
y <- cbind(y[,2],y[,1])
pendulum <- list(N,ts,y_init,y,sigma)


model <- stan_model("pendulum.stan")
fit <- sampling(model, data = pendulum, seed = 123,chains=4,iter=1000, control = list(adapt_delta = 0.99))
print(fit, pars=c("params","z_init"),probs=c(0.1,0.5,0.9),digits=3)


#posterior <- extract(fit)
#for(i in 1:250){
	#sprintf("%f",posterior$params[i])
#	print(posterior$params[i])
#}

