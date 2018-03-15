data = load('22stocks.csv');
FTSE100 = load('FTSE100.csv');
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
n = 758/2;
% get 5 stocks
numStocks = 5;
% using sparse index tracking to select 5 stocks
% use cvx to get minimum weights
% taw is the penalty of regularisation
a = zeros(n,1);
for i = 1:n
    a(i) = mean(returnsTrain(i,:));
end
taw = 250;
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

ax1 = subplot(2,1,1);
grid on;
box on;
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
grid on;
box on;
hold on;
plot(ax2,ftseTest,'g','LineWidth',3);
plot(ax2,avgReturnTest,'r','LineWidth',3);
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
