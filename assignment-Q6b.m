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
grid on;
box on;
ax1 = subplot(2,1,1);
hold on;
plot(ax1,ftseTrain,'g','LineWidth',3);
plot(ax1,avgReturnTrain,'r','LineWidth',3);
plot(ax1,returnsTrain,'b');
xlabel(ax1,'Days');
ylabel(ax1,'Returns');
title(ax1,'Training set','FontSize',14);
legend('Returns of FTSE100','Returns of selected stocks','Returns of 22 stocks','Location','northwest');
% plot testing set
ax2 = subplot(2,1,2);
hold on;
plot(ax2,ftseTest,'g','LineWidth',3);
plot(ax2,avgReturnTest,'r','LineWidth',3);
plot(ax2,returnsTest,'b');
xlabel(ax2,'Days');
ylabel(ax2,'Returns');
title(ax2,'Testing set','FontSize',14);
% tracking error
normalisedTest = zeros(n,numStocks);
normalisedTest2 = zeros(n,numStocks);
normalisedftseTest = zeros(n,1);
normalisedAvgTest = zeros(n,1);
tempAvgTest = returnsTest(:,idxStocks);
for i = 1:numStocks
    normalisedTest(:,i) = tempAvgTest(:,i) - mean(tempAvgTest(:,i));
    normalisedTest(:,i) = normalisedTest(:,i) / std(normalisedTest(:,i));
end
for i = 1:n
    normalisedftseTest(i) = ftseTest(i) - mean(ftseTest);
    normalisedftseTest(i) = normalisedftseTest(i) / std(ftseTest);
end
for i = 1:n
    normalisedAvgTest(i) = mean(normalisedTest(i,:));
end
[InfoRatio, TrackingError] = inforatio(normalisedAvgTest, normalisedftseTest)