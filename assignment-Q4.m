stock1 = load("CCH.csv");
stock2 = load("GFS.csv");
stock3 = load("SKY.csv");
[rows,cols] = size(stock1);
for i = 1:cols
    stock1(:,i) = stock1(:,i) - mean(stock1(:,i));
    stock1(:,i) = stock1(:,i) / std(stock1(:,i));
    stock2(:,i) = stock2(:,i) - mean(stock2(:,i));
    stock2(:,i) = stock2(:,i) / std(stock2(:,i));
    stock3(:,i) = stock3(:,i) - mean(stock3(:,i));
    stock3(:,i) = stock3(:,i) / std(stock3(:,i));
end
return1 = zeros(rows/2,1);
return2 = zeros(rows/2,1);
return3 = zeros(rows/2,1);
returnT1 = zeros(rows/2,1);
returnT2 = zeros(rows/2,1);
returnT3 = zeros(rows/2,1);
for i = 1:rows/2
    return1(i,1) = stock1(i,4) - stock1(1,4);
    return2(i,1) = stock2(i,4) - stock2(1,4);
    return3(i,1) = stock3(i,4) - stock3(1,4);
end
for i = 1:rows/2
    returnT1(i,1) = stock1(rows/2+i,4) - stock1(rows/2+1,4);
    returnT2(i,1) = stock2(rows/2+i,4) - stock2(rows/2+1,4);
    returnT3(i,1) = stock3(rows/2+i,4) - stock3(rows/2+1,4);
end
% return
trainRe1 = mean(return1(1:rows/2));
trainRe2 = mean(return2(1:rows/2));
trainRe3 = mean(return3(1:rows/2));
testRe1 = mean(returnT1(1:rows/2));
testRe2 = mean(returnT2(1:rows/2));
testRe3 = mean(returnT3(1:rows/2));
re = [return1 return2 return3];
reT = [returnT1 returnT2 returnT3];
trainRet = re(1:rows/2,:);
testRet = reT(1:rows/2,:);
ECov = cov(trainRet);
NPts = 20;
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
colormap = autumn(NPts);
colormap = colormap(1:end,:);

figure;
box on;
hold on;
grid on;
plot(naiveRet,'b','LineWidth',2);
plot(efficientRetAverage,'r','LineWidth',4);
% efficientRet = fliplr(efficientRet);
for i = 1:NPts
    plot(efficientRet(:,i),'LineWidth',1,'Color',colormap(i,:));
end
% efficientRet = fliplr(efficientRet);
legend("Naive 1/N returns","Average efficient returns","Efficient returns",'Location','northwest');
title("Different returns of 3 stocks",'FontSize',16);
xlabel("Days",'FontSize',14);
ylabel("Returns",'FontSize',14);

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
end
sharpeEfficient = fliplr(sharpeEfficient);
xlabel('Portfolio', 'FontSize', 18);
ylabel('Ratio', 'FontSize', 18);
title(strcat('Sharpe Ratio - Risk Free:', int2str(riskFree*100) ,'%' ), 'FontSize', 18);
legend('Naive 1/N Portfolio', 'Efficient Portfolio Avg.', 'Efficient Portfolios');
