load('c2925.mat');
[rows, cols] = size(c2925);
strike = 2925;
rate = 0.06;
time = 0.6;
N = 50;
volatility = 0.12;
price = zeros(rows,1);
price(:,1) = c2925(1:rows,3);
k = randperm(rows,1);
% black-sholes model
[Call, Put] = blsprice(price(k),strike,rate,time,volatility);
% binomial lattice model
LatticeC = zeros(1,N);
for i = 1:N
    LatticeC(i) = LatticeEurCall(price(k),strike,rate,time,volatility,i);
end
figure;
plot(1:N, ones(1,N)*Call);
hold on;
plot(1:N,LatticeC);
