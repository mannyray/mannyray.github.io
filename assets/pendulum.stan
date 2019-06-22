functions {
	real[] dz_dt(real t, real[] z, real[] params, real[] x_r, int[] x_i){
		real velocity = z[1];
		real theta = z[2];	
		real g = 9.81;
		real damping = 5e-1;
		real length = params[1];

		real rh_v = -(g/length)*sin(theta) - damping*velocity; 
		real rh_th = velocity;

		return {rh_v, rh_th};	
	}
}
data {
	int <lower = 0 > N;//number of measurement times
	real ts[N]; //measurement times > 0
	real y_init[2]; //initial measured populations
	real y[N,2];//measured velocity and theta
	real <lower = 0> sigma[2];
}
parameters{
	real <lower = 0> params[1]; 
	real z_init[2]; //initial velocity and theta values
}
transformed parameters{
	real z[N,2] = integrate_ode_rk45(dz_dt, z_init, 0, ts, params, rep_array(0.0,0), rep_array(0,0), 1e-6, 1e-5, 1e6);
}
model {
	params[1] ~ normal(1.9,0.1);
	z_init[1] ~ normal(0,0.01);//velocity
	z_init[2] ~ normal(pi()-0.1,0.01);//theta
	for (k in 1:2){
		y_init[k] ~ normal((z_init[k]), sigma[k]);
		y[,k] ~ normal((z[,k]),sigma[k]);
	}
}
generated quantities{
	real y_init_rep[2];
	real y_rep[N,2];
	for (k in 1:2){
		y_init_rep[k] = normal_rng((z_init[k]),sigma[k]);
		for (n in 1:N){
			y_rep[n,k] = normal_rng((z[n,k]),sigma[k]);
		}
	}
}

