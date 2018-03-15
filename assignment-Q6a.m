data = load('22stocks.csv');
FTSE100 = load('FTSE100.csv');
returns = zeros(758,22);
ftseTrain = zeros(379,1);
ftseTest = zeros(379,1);
% calculate returns of 22 stocks, each column is one stock
% training return
returnsTrain = zeros(379,22);
returnsTest = zeros(379,22);
m = 0;
for i = 1:22
    for j = 1:379
        returnsTrain(j,i) = data(j+m,4) - data(1+m,4);
    end
    m = m+758;
end
% testing return
m = 0;
for i = 1:22
    for j = 1:379
        returnsTest(j,i) = data(379+j+m,4) - data(379+1+m,4);
    end
    m = m+758;
end
% training returns of FTSE100
for i = 1:379
    ftseTrain(i) = FTSE100(i) - FTSE100(1);
end
% testing returns of FTSE100
for i = 1:379
    ftseTest(i) = FTSE100(379+i) - FTSE100(1+379);
end

% using greedy alogithm to select 5 stocks --------------------------
n = 379;
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

ax1 = subplot(2,1,1);
grid on;
box on;
hold on;
plot(ax1,ftseTrain,'g','LineWidth',3);
plot(ax1,avgRetTrain,'r','LineWidth',3);
plot(ax1,returnsTrain,'b');
xlabel(ax1,'Days');
ylabel(ax1,'Returns');
title(ax1,'Training set','FontSize',14);
legend('Returns of FTSE100','Returns of selected stocks','Returns of 22 stocks','Location','northwest');
% plot testing set
ax2 = subplot(2,1,2);
grid on;
box on;
hold on;
plot(ax2,ftseTest,'g','LineWidth',3);
plot(ax2,avgRetTest,'r','LineWidth',3);
plot(ax2,returnsTest,'b');
xlabel(ax2,'Days');
ylabel(ax2,'Returns');
title(ax2,'Testing set','FontSize',14);
legend('Returns of FTSE100','Returns of selected stocks','Returns of 22 stocks','Location','northwest');

% tracking error
normalisedTest = zeros(n,numStocks);
normalisedTest2 = zeros(n,numStocks);
normalisedftseTest = zeros(n,1);
normalisedAvgTest = zeros(n,1);
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
