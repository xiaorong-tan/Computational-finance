data = load('22stocks.csv');
FTSE100 = load('FTSE100.csv');
returns = zeros(758,22);
ftse = zeros(758,1);
% calculate returns of 22 stocks, each column is one stock
m = 0;
for i = 1:22
    for j = 2:758
        returns(j,i) = data(j+m,4) - data(1+m,4);
    end
    m = m+758;
end
% returns of FTSE100
for i = 2:758
    ftse(i) = FTSE100(i) - FTSE100(1);
end
% split returns of 22 stocks to train set and test set
n = 758/2;
returnsTrain = returns(1:n,:);
returnsTest = returns(n+1:758,:);
ftseTrain = ftse(1:n);
ftseTest = ftse(n+1:758);
% get 5 stocks
numStocks = 5;
% using sparse index tracking to select 5 stocks
% use cvx to get minimum weights
% taw is the penalty of regularisation
a = zeros(n,1);
for i = 1:n
    a(i) = mean(returnsTrain(i,:));
end
taw = 100;
cvx_begin
   variable x(22,1);
   minimize(norm((ftseTrain - returnsTrain*x),2) + norm((taw*x),1));
   subject to
   x >= zeros(22,1);
cvx_end
[weights, idxStocks] = sort(x,'descend');
weights = weights(1:numStocks);
idxStocks = idxStocks(1:numStocks);
% get the avergage returns of selected 5 stocks
avgReturnTrain = returnsTrain(:, idxStocks)*weights;
avgReturnTest = returnsTest(:,idxStocks)*weights;
% plot training set
figure;
hold on;
grid on;
box on;
plot(ftseTrain,'g','LineWidth',2);
plot(avgReturnTrain,'r','LineWidth',2);
plot(returnsTrain,'b');
xlabel('Days');
ylabel('Returns');
title('Sparse Index tracking (Training set)');
legend('Returns of FTSE100','Returns of selected stocks','Returns of 22 stocks');
% plot testing set
figure;
hold on;
grid on;
box on;
plot(ftseTest,'g','LineWidth',2);
plot(avgReturnTest,'r','LineWidth',2);
plot(returnsTest,'b');
xlabel('Days');
ylabel('Returns');
title('Sparse Index tracking (Testing set)');
legend('Returns of FTSE100','Returns of selected stocks','Returns of 22 stocks');