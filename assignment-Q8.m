load('c2925.mat');load('p2925.mat');load('c3025.mat');load('p3025.mat');
load('c3125.mat');load('p3125.mat');load('c3225.mat');load('p3225.mat');
load('c3325.mat');load('p3325.mat');
strike = [2925;3025;3125;3225;3325];
[rows,cols] = size(c2925);
T = floor(rows/4);
price = zeros(rows-T-1,1);
%price(:,1) = c2925(2:rows-T,3);
price(:,1) = c2925(T+2:rows,3);
% calculate returns (from Day 2)
ftse = zeros(rows,1);
ftse(:,1) = c2925(1:rows,3);
returns = zeros(rows-1,1);
for i = 1:rows-1
    returns(i,1) = log(ftse(i+1,1)/ftse(i,1));
end
% calculate volatitily (sliding window range T)
volatility = zeros(rows-1-T,1);
r = 0;
for i = 1:rows-1-T
    volatility(i,1) = std(returns(1+r:T+r,1))*sqrt(222);
    r = r+1;
end
[Call1, Put1] = blsprice(price,strike(1),0.06,0.6,volatility); %2925
[Call2, Put2] = blsprice(price,strike(2),0.06,0.6,volatility); %3025
[Call3, Put3] = blsprice(price,strike(3),0.06,0.6,volatility); %3125
[Call4, Put4] = blsprice(price,strike(4),0.06,0.6,volatility); %3225
[Call5, Put5] = blsprice(price,strike(5),0.06,0.6,volatility); %3325
figure;
ax1 = subplot(2,1,1);
box on;
grid on;
hold on;
plot(ax1,c2925(T+2:end,2),'r');
plot(ax1,Call1,'b');
xlabel(ax1,"Days",'FontSize',14);
ylabel(ax1,"Call Price",'FontSize',14);
title(ax1,"Black-Scholes model - Call Price(Strike:2925)",'FontSize',16);
legend("True price","Estimated price");
ax2 = subplot(2,1,2);
box on;
grid on;
hold on;
plot(ax2,p2925(T+2:end,2),'r');
plot(ax2,Put1,'b');
xlabel(ax2,"Days",'FontSize',14);
ylabel(ax2,"Put Price",'FontSize',14);
title(ax2,"Black-Scholes model - Put Price",'FontSize',16);
legend("True price","Estimated price");

% implied volatility
temp_c2925 = c2925(T+2:end,:);
temp_c3025 = c3025(T+2:end,:);
temp_c3125 = c3125(T+2:end,:);
temp_c3225 = c3225(T+2:end,:);
temp_c3325 = c3325(T+2:end,:);
k = 90;
idx = randperm(166,k);
value = zeros(k,5);
value(:,1) = temp_c2925(idx,2);
value(:,2) = temp_c3025(idx,2);
value(:,3) = temp_c3125(idx,2);
value(:,4) = temp_c3225(idx,2);
value(:,5) = temp_c3325(idx,2);
temp_price = zeros(k,1);
temp_price = temp_c2925(idx,3);
rate = 0.06;
time = 0.6;
Volatility = zeros(k,5);
Volatility(:,1) = blsimpv(temp_price,strike(1),rate,time,value(:,1));
Volatility(:,2) = blsimpv(temp_price,strike(2),rate,time,value(:,2));
Volatility(:,3) = blsimpv(temp_price,strike(3),rate,time,value(:,3));
Volatility(:,4) = blsimpv(temp_price,strike(4),rate,time,value(:,4));
Volatility(:,5) = blsimpv(temp_price,strike(5),rate,time,value(:,5));
temp_vola = zeros(k,1);
temp_vola(:,1) = volatility(idx);
figure;
boxplot([Volatility(:,1) Volatility(:,2) Volatility(:,2) Volatility(:,4) Volatility(:,5)],'Notch','on','Labels',{'2925','3025','3125','3225','3325'});