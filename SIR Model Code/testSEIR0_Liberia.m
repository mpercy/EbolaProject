% A function to run the ODE and return the value for I
% intervention day Aug 4
% day 0 is March 22
% On March 31, 2014 Liberia confirmed its first two cases of Ebola virus
% disease, one died, one infected
% therefore, tau is around 110


function SEIR0_Liberia
    load finalDatLib
    idxI = idxI(18:end);
    idxD = idxD(18:end);
    if 1==0
        testOnevalue([  1.0000   21.0000   10.7000    0.9000], day1, infected, death, idxI, idxD);
    else
        d = [];
        i = [];
        beta1 = [0:0.1:1];
        beta2 = [0:0.1:1];
        meanIncubation = [1:1:21];
        meanRecovered = [3.5:0.3:10.7];
        resI = 2*ones(length(beta1),length(beta2),length(meanIncubation), length(meanRecovered));
        resD = 2*ones(length(beta1),length(beta2),length(meanIncubation), length(meanRecovered));
        q1 = 2;
        rmin = 2;
        dmin = 2;
        valI = [];
        valD = [];
        for counter1 = 1:length(beta1)
            counter1
            for counter2 = 1:length(beta2)
                if (beta1(counter1) > beta2(counter2))
                    for q = q1
                        for counter3 = 1:length(meanIncubation)
                            for counter4 = 1:length(meanRecovered)
                                [t, infected1, death1] = SEIR0Liberia(beta1(counter1),meanIncubation(counter3), meanRecovered(counter4), beta2(counter2),q);
                                bb = infected1(day(idxI));
                                aa =  infected(idxI);
                                
                                dd = death1(day(idxD));
                                cc = death(idxD);
                                
                                rI = sum((aa-bb).^2)/sum(aa.^2);
                                dI = sum((cc-dd).^2)/sum(cc.^2);
                               
                                resI(counter1,counter2,counter3,counter4) =rI;
                                resD(counter1,counter2,counter3,counter4) = dI;
                                
                                if (rI < rmin)
                                    rmin = rI;
                                    valI = [beta1(counter1),meanIncubation(counter3), meanRecovered(counter4), beta2(counter2)];
                                end
                                
                                if (dI < dmin)
                                    dmin = dI;
                                    valD = [beta1(counter1),meanIncubation(counter3), meanRecovered(counter4), beta2(counter2)];
                                end

                            end
                        end
                    end
                end
            end
        end
        
        save result1  resI resD valI valD
        
    end
end

function testOnevalue(beta, day, infected, death, idxI, idxD)
    figure
    [t, infected1, death1] = SEIR0Liberia(beta(1),beta(2),beta(3),beta(4),beta(5));
    plot(t, infected1);
    hold on
    plot(day(idxI), infected(idxI));
    plot(t, death1,'r')
    plot(day(idxD), death(idxD),'r')
end

function [t, infected, death] = SEIR0Liberia(a,b,c,d,e) 
b0 = a; % transmission rate per person per day range 0<b<1
k0 = 1/b; % mean incubation period (1/k) is 6.3 days, range 1<(1/k)<21] %5.5
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
tau = 50;

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
