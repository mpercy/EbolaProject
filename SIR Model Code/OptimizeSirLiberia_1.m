function OptimizeSirLiberia
lowerBound = [0.0001 3.5  0.0001   1];
upperBound = [1 10.7 1   100];

load dataLiberiaUpdated
%param0 = [ 0.3000   13.5000    7.5000    0.2000   10.0000];
param0 = [0.4106    3.9068    3.5918    0.3307    6.0960   50.7888];% [ 0   13.5000    7.5000    0.2000   10.0000];
param0 = [ 0.2050     8.6000    0.1500    0.1000];
param0 = [ 0.2050     8.6000    0.1500    0.1000];
param0 = [ 0.4050     8.6000    0.200    0.8000];

param0 =  [  0.1880     8.94    0.1573   4];

% lsqnonlin will return the parameter values for beta and gamma and the norm
% of the residual function
options = optimset('MaxFunEvals',4000);
[p,resnorm] = lsqnonlin(@SEIR1,param0,lowerBound,upperBound,options,infected, dayI);
p
resnorm
testOnevalue(p, dayI, infected);

end
function res = SEIR1(input,infected, dayI) 
b0 = input(1); % transmission rate per person per day range 0<b<1
k0 = 1/6.3; % mean incubation period (1/k) is 6.3 days, range 1<(1/k)<21] %5.5
g0 = 1/input(2); % recovered/death rate (per capita), 1/g is the infectious period. 3.5 < 1/g < 10.7
b1 = input(3);
q = input(4);
p0  = [b0 g0 b1 q];


% Redeclare initial conditions and N
N = 1000000;
x0 = [N-2 1 0 1];

% Set up the parameter vector to be passed
p = [N p0];

tspan =0:1:210;
% Calls the ODE solver with the current parameter guess
[t,y] = ode45(@SEIR,tspan,x0,[],p);
I = cumsum(y(:,2)*k0);
val = mean((infected - I(dayI)).^2) / mean(infected.^2);
disp(p0);
disp(val)

res = (infected - I(dayI));
vpred = I(dayI);
vpred(vpred<=0) = 1e-3;
lll = sum(vpred-infected.*log(vpred)).^2;
disp(lll);
end



% The function containing the ODEs
function y = SEIR(t,x,p)

N = p(1);
b0 = p(2);
%k = p(3);
k = 1/6.3;
g = p(3);
b1 = p(4);
q = p(5);
%tau = 110;
%tau = p(7);
tau = 120;
S = x(1);
E = x(2);
I = x(3);
R = x(4);


if t<tau
    b = b0;
else
    b = b1 + (b0-b1)*exp(-q*(t-tau));
end

y = [- (b.* S* I /N);
(b .* S * I / N) - (k * E);
(k * E) - (g * I)
(g * I)];

end

