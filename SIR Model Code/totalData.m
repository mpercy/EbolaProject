load dataTotal

day1 =double(day);
death =double(death);
infected = double(infected);

day1 = day1+110; % first day in day1 is march 22
tau = 110;

idxI = find(infected>0);
dayI = day1(idxI);
infected = infected(idxI);

idxD = find(death>0);
dayD = day1(idxD);
death = death(idxD);

save dataTotal1 infected death dayI dayD tau