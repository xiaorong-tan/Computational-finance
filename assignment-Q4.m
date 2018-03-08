stock1 = load("CCH.csv");
stock2 = load("GFS.csv");
stock3 = load("SKY.csv");
[rows,cols] = size(stock1);
return1 = zeros(rows,1);
return2 = zeros(rows,1);
return3 = zeros(rows,1);
for i = 2:rows
    return1(i,1) = stock1(i,4) - stock1(1,4);
    return2(i,1) = stock2(i,4) - stock2(1,4);
    return3(i,1) = stock3(i,4) - stock3(1,4);
end
% return
trainRe1 = mean(return1(1:rows/2));
trainRe2 = mean(return2(1:rows/2));
trainRe3 = mean(return3(1:rows/2));
testRe1 = mean(return1(rows/2+1:rows));
testRe2 = mean(return2(rows/2+1:rows));
testRe3 = mean(return3(rows/2+1:rows));
re = [return1 return2 return3];
trainRet = re(1:rows/2,:);
testRet = re(rows/2+1:rows,:);
for i = 1:3
    trainRet(:,i) = trainRet(:,i) - mean(trainRet(:,i));
    trainRet(:,i) = trainRet(:,i) / std(trainRet(:,i));
    testRet(:,i) = testRet(:,i) - mean(testRet(:,i));
    testRet(:,i) = testRet(:,i) / std(testRet(:,i));
end
ECov = cov(trainRet);
NPts = 10;
ERet = [trainRe1 trainRe2 trainRe3]';
[PRisk, PRoR, PWts] = naiveMV(ERet, ECov, NPts);
%get the weights for one portfolio using naiive method (i.e 1/n)
% i.e. portfolio consists of assets with the same weights
naiveWeights = ones(1,3)*(1/3);

% calcuate the returns for the test data using the 2 different
% weights: the efficient-frontier weights, and the naive weights
efficientRet = zeros(rows/2,NPts);
for i = 1:NPts
    efficientRet = testRet * PWts';
end
naiveRet = testRet*naiveWeights';
% get the average of all efficient returns
efficientRetAverage = zeros(rows/2,1);
for i = 1:rows/2
    efficientRetAverage(i,1) = mean(efficientRet(i,:));
end
colormap = summer(NPts);
colormap = colormap(1:end,:);

figure;
box on;
hold on;
grid on;
plot(naiveRet,'b');
plot(efficientRetAverage,'g');
% efficientRet = fliplr(efficientRet);
for i = 1:NPts
    plot(efficientRet(:,i),'LineWidth',1,'Color',colormap(i,:));
end
% efficientRet = fliplr(efficientRet);
legend("Efficient returns","Naive returns","Mean of efficient returns");
title("2 different returns");
xlabel("Days");
ylabel("Returns");

% calculate sharpe ratio
riskFree = 0.2;
sharpeEfficient = zeros(1, NPts);
for i=1:NPts
    sharpeEfficient(i) = (mean(efficientRet(:,i)) - riskFree)/std(efficientRet(:,i));
end
sharpeNaive = (mean(naiveRet) - riskFree)/std(naiveRet);
sharpeEfficientAverage = mean(sharpeEfficient);
colormap = autumn(NPts);
figure;
hold on;
grid on;
plot([1 NPts],[sharpeNaive sharpeNaive],'LineWidth',2,'Color','b');
plot([1 NPts],[sharpeEfficientAverage sharpeEfficientAverage],'LineWidth',2,'Color',[0 0.7 0.2]);
sharpeEfficient = fliplr(sharpeEfficient);
for i=1:NPts
    plot(i, sharpeEfficient(i), '.r', 'MarkerSize', 30, 'Color', colormap(i,:));
    plot(i, sharpeEfficient(i), '.k', 'MarkerSize', 10);
end
sharpeEfficient = fliplr(sharpeEfficient);
xlabel('Portfolio', 'FontSize', 18);
ylabel('Ratio', 'FontSize', 18);
title(strcat('Sharpe Ratio - Risk Free:', int2str(riskFree*100) ,'%' ), 'FontSize', 18);
legend('Naive Portfolio', 'Efficient Portfolio Avg.', 'Efficient Portfolios');