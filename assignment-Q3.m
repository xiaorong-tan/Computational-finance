ERet = [0.15 0.2 0.08]';
ECov = [0.2 0.05 -0.01;0.05 0.3 0.015;-0.01 0.015 0.1];
NPts = 10;
[PRisk1, PRoR1, PWts1] = naiveMV_CVX(ERet, ECov, NPts);
plot(PRisk1,PRoR1);
title("Efficient Frontier");
xlabel("Risk");
ylabel("Return");

% using naiveMV function ------------------------------------
[PRisk1, PRoR1, PWts1] = naiveMV(ERet, ECov, NPts);
figure;
plot(PRisk1,PRoR1);
title("Different ways to produce efficient frontier",);
xlabel("Risk");
ylabel("Return");

% using Q2 data --------------------------------------
m = [ 0.1;0.2;0.15 ];
C = [0.005 -0.01 0.004;
    -0.01 0.04 -0.002;
    0.004 -0.002 0.023];
[PRisk, PRoR, PWts] = naiveMV(m, C, 100);
m1 = [0.1;0.2];
C1 = [0.005 -0.01;-0.01 0.04];
[PRisk1, PRoR1, PWts1] = naiveMV(m1, C1, 33);
m2 = [0.1;0.15];
C2 = [0.005 0.004;0.004 0.023];
[PRisk2, PRoR2, PWts2] = naiveMV(m2, C2, 33);
m3 = [0.2;0.15];
C3 = [0.04 -0.002;-0.002 0.023];
[PRisk3, PRoR3, PWts3] = naiveMV(m3, C3, 33);
AssetScenarios = mvnrnd(m, C, 100);
total = sum(AssetScenarios,2);
total = total(:,ones(3,1));
weights = AssetScenarios./total;
[PortRisk, PortReturn] = portstats(m', C, weights);
figure;
hold on
plot(PRisk,PRoR),plot(PRisk1,PRoR1),plot(PRisk2,PRoR2),plot(PRisk3,PRoR3),plot(PortRisk,PortReturn,'.r');
title("Efficient Frontier");
xlabel("Risk");
ylabel("Return");