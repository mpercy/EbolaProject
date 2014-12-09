% A function to run the ODE and return the value for I
% intervention day Aug 4
% day 0 is March 22
% On March 31, 2014 Liberia confirmed its first two cases of Ebola virus
% disease, one died, one infected
% therefore, tau is around 110


function SEIR0_Liberia
    load dataLiberiaUpdated
    if 1==0
        %for q = [0:0.01:1]
            %beta1 = [0.3000   13.5000    7.5000    0.2000    q];
            beta1 = [ 0.3000   16.0000    8.0000         0    0.0100];
            beta1 = [0.2600    6.0000    6.0000    0.1500    0.0100];
            beta1 = [    0.2000    6.3000    9.0000    0.1500    0.6000];
            beta1 = [0.2050    6.3000    8.6000    0.1500    0.1000];
            testOnevalue(beta1, day1, infected, death, idxI, idxD);

        %end
        %beta1 = [0.4000   17.5000    9.0000    0.2000    5.0000];
    else
        counter =0;
        d = [];
        i = [];
        beta0Range = [0.0001:0.01:0.3];
        beta1Range = [0.0001:0.01:0.2];
        kOptim = 6.3;        
        gammaRange = [3:0.5:10.7];
        qRange = [0.001:0.1:2 3:7:100];
        
        ll = [];
        imin = 1000000;
        
        for a = beta0Range
            for a1 = beta1Range
                if (a > a1)
                    for q = qRange
                        for b = kOptim
                            for c = gammaRange
                                if rem(counter,1000)==0
                                    disp(counter);
                                end
                                counter=counter+1;
                                [t, infected1, death1] = SEIR0Liberia(a,b,c,a1,q);
                                itemp = mean( ( infected -  infected1(dayI) ).^2 )./mean( infected.^2 );
                                ll =[ll itemp];


                                if (imin>itemp)
                                    valI = [a b c a1 q];
                                    imin = itemp;
                                    disp(valI)
                                    disp(imin)
                                end
                            end
                        end
                    end
                end
            end
        end
        
        save resultLiberiaLatinSquare_1  imin valI ll beta0Range beta1Range qRange gammaRange
        
    end
end

function testOnevalue(beta, day1, infected, death, idxI, idxD)
    hold on
    [t, infected1, death1] = SEIR0Liberia(beta(1),beta(2),beta(3),beta(4),beta(5));
    res = mean( (infected(idxI) -  infected1(day1(idxI))).^2 )./mean( infected(idxI).^2 );
    disp(res);
    plot(t, infected1);
    hold on
    plot(day1(idxI), infected(idxI));
    plot(t, 0.65*death1,'r')
    plot(day1(idxD), death(idxD),'r')
end

function [t, infected, death] = SEIR0Liberia(a,b,c,d,e) 
b0 = a; % transmission rate per person per day1 range 0<b<1
k0 = 1/b; % mean incubation period (1/k) is 6.3 day1s, range 1<(1/k)<21] %5.5
g0 = 1/c; % recovered/death rate (per capita), 1/g is the infectious period. 3.5 < 1/g < 10.7

p0  = [b0 k0 g0 d e];


% Redeclare initial conditions and N
N = 1000000;
x0 = [N-2 0 1 1];

% Set up the parameter vector to be passed
p = [N p0];

tspan =0:1:210;
% Calls the ODE solver with the current parameter guess
[t,y] = ode45(@SEIR,tspan,x0,[],p);
infected = cumsum(y(:,2)*k0);
death = cumsum(y(:,3)*g0);


end

function y = SEIR(t,x,p)

N = p(1);
b0 = p(2);
k = p(3);
g = p(4);
b1 = p(5);
q = p(6);


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
