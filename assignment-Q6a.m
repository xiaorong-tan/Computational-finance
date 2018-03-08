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
% using greedy alogithm to select 5 stocks --------------------------
numStocks = 5;
selectedStocks = zeros(1,numStocks);
allStocks = 1:22;
%greedy forward selection algorithm
for i = 1:numStocks
    avgReturns = zeros(length(allStocks),1);
    for j = 1:length(allStocks)
        idx = [nonzeros(selectedStocks)' allStocks(j)];
        portRet = returnsTrain(:,idx);
        rows = size(portRet,1);
        tempRet = zeros(rows,1);
        for k = 1:rows
            tempRet(k) = mean(portRet(k,:));
        end
        avgReturns(j) = mean(tempRet);
    end
    [~,idx] = max(avgReturns);
    selectedStocks(i) = allStocks(idx);
    allStocks(idx) = [];
end
% returns of selected stocks
avgRetTrain = zeros(rows,1);
avgRetTest = zeros(rows,1);
tempAvgTrain = returnsTrain(:,selectedStocks);
tempAvgTest = returnsTest(:,selectedStocks);
% average returns of selected stocks
for i = 1:rows
    avgRetTrain(i) = mean(tempAvgTrain(i,:));
    avgRetTest(i) = mean(tempAvgTest(i,:));
end
% plot training set
hold on;
grid on;
box on;
plot(ftseTrain,'g','LineWidth',2);
plot(avgRetTrain,'r','LineWidth',2);
plot(returnsTrain,'b');
xlabel('Days');
ylabel('Returns');
title('Index tracking (Training set)');
legend('Returns of FTSE100','Returns of selected stocks','Returns of 22 stocks');
% plot testing set
figure;
hold on;
grid on;
box on;
plot(ftseTest,'g','LineWidth',2);
plot(avgRetTest,'r','LineWidth',2);
plot(returnsTest,'b');
xlabel('Days');
ylabel('Returns');
title('Index tracking (Testing set)');
legend('Returns of FTSE100','Returns of selected stocks','Returns of 22 stocks');