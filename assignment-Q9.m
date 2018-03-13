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
temp_p2925 = p2925(T+2:end,:);
temp_p3025 = p3025(T+2:end,:);
temp_p3125 = p3125(T+2:end,:);
temp_p3225 = p3225(T+2:end,:);
temp_p3325 = p3325(T+2:end,:);
% rand number
k = 30;
idx = randperm(166,k);
value = zeros(k,5);
value(:,1) = temp_c2925(idx,2);
value(:,2) = temp_c3025(idx,2);
value(:,3) = temp_c3125(idx,2);
value(:,4) = temp_c3225(idx,2);
value(:,5) = temp_c3325(idx,2);
putValue = zeros(k,5);
putValue(:,1) = temp_p2925(idx,2);
putValue(:,2) = temp_p3025(idx,2);
putValue(:,3) = temp_p3125(idx,2);
putValue(:,4) = temp_p3225(idx,2);
putValue(:,5) = temp_p3325(idx,2);
temp_price = zeros(k,1);
temp_price = temp_c2925(idx,3);
rate = 0.06;
time = 0.6;
Volatility = zeros(k,10);
Volatility(:,1) = blsimpv(temp_price,strike(1),rate,time,value(:,1));
Volatility(:,2) = blsimpv(temp_price,strike(2),rate,time,value(:,2));
Volatility(:,3) = blsimpv(temp_price,strike(3),rate,time,value(:,3));
Volatility(:,4) = blsimpv(temp_price,strike(4),rate,time,value(:,4));
Volatility(:,5) = blsimpv(temp_price,strike(5),rate,time,value(:,5));
Volatility(:,6) = blsimpv(temp_price,strike(1),rate,time,putValue(:,1));
Volatility(:,7) = blsimpv(temp_price,strike(5),rate,time,putValue(:,2));
Volatility(:,8) = blsimpv(temp_price,strike(5),rate,time,putValue(:,3));
Volatility(:,9) = blsimpv(temp_price,strike(5),rate,time,putValue(:,4));
Volatility(:,10) = blsimpv(temp_price,strike(5),rate,time,putValue(:,5));
temp_vola = zeros(k,1);
temp_vola(:,1) = volatility(idx);
% plot scatter points of estimated volatility and implied volatility (call option)
figure;
box on;
grid on;
hold on;
plot(temp_vola,'or','MarkerSize',5);
plot(Volatility(:,1),'c+','MarkerSize',7);
plot(Volatility(:,2),'k+','MarkerSize',7);
plot(Volatility(:,3),'b+','MarkerSize',7);
plot(Volatility(:,4),'g+','MarkerSize',7);
plot(Volatility(:,5),'m+','MarkerSize',7);
xlabel("Days",'FontSize',14);
ylabel("Implied volatility",'FontSize',14);
title("Implied Volatility (Call Option)",'FontSize',16);
legend("Realised Volatility","Strike 2925","Strike 3025","Strike 3125","Strike 3225","Strike 3325");

% plot scatter points of estimated volatility and implied volatility (put option)
figure;
box on;
grid on;
hold on;
plot(temp_vola,'or','MarkerSize',5);
plot(Volatility(:,6),'c+','MarkerSize',7);
plot(Volatility(:,7),'k+','MarkerSize',7);
plot(Volatility(:,8),'b+','MarkerSize',7);
plot(Volatility(:,9),'g+','MarkerSize',7);
plot(Volatility(:,10),'m+','MarkerSize',7);
xlabel("Days",'FontSize',14);
ylabel("Implied volatility",'FontSize',14);
title("Implied Volatility (Put Option)",'FontSize',16);
legend("Realised Volatility","Strike 2925","Strike 3025","Strike 3125","Strike 3225","Strike 3325",'Location','northwest');

% plot volatility smile.
smile = zeros(5,2);
smile(1,1) = Volatility(62,1); % Call option
smile(2,1) = Volatility(62,2);
smile(3,1) = Volatility(62,3);
smile(4,1) = Volatility(62,4);
smile(5,1) = Volatility(62,5);
smile(1,2) = Volatility(62,6); % Put option
smile(2,2) = Volatility(62,7);
smile(3,2) = Volatility(62,8);
smile(4,2) = Volatility(62,9);
smile(5,2) = Volatility(62,10);
% plot call option
figure;
ax1 = subplot(2,1,1);
box on;
grid on;
hold on;
plot(ax1,smile(:,1));
plot(ax1,smile(:,1),'ob','MarkerSize',7);
xlabel(ax1,"Strike Price",'FontSize',14);
ylabel(ax1,"Implied Volatility",'FontSize',14);
title(ax1,"Smile Volatility (Call Option)",'FontSize',16);
xticks([1 2 3 4 5])
xticklabels({'2925','3025','3125','3225','3325'});
% plot put option
ax2 =subplot(2,1,2);
box on;
grid on;
hold on;
plot(ax2,smile(:,2));
plot(ax2,smile(:,2),'ob','MarkerSize',7);
xlabel(ax2,"Strike Price",'FontSize',14);
ylabel(ax2,"Implied Volatility",'FontSize',14);
xticks([1 2 3 4 5])
xticklabels({'2925','3025','3125','3225','3325'});
title(ax2,"Smile Volatility (Put Option)",'FontSize',16);
