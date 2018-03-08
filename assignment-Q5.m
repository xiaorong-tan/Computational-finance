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
% non-mispricing naiveMV model
nonM_trainRe1 = mean(return1(1:rows/2));
nonM_trainRe2 = mean(return2(1:rows/2));
nonM_trainRe3 = mean(return3(1:rows/2));
testRe1 = mean(return1(rows/2+1:rows));
testRe2 = mean(return2(rows/2+1:rows));
testRe3 = mean(return3(rows/2+1:rows));
re = [return1 return2 return3];
nonM_trainRet = re(1:rows/2,:);
testRet = re(rows/2+1:rows,:);
for i = 1:3
    nonM_trainRet(:,i) = nonM_trainRet(:,i) - mean(nonM_trainRet(:,i));
    nonM_trainRet(:,i) = nonM_trainRet(:,i) / std(nonM_trainRet(:,i));
    testRet(:,i) = testRet(:,i) - mean(testRet(:,i));
    testRet(:,i) = testRet(:,i) / std(testRet(:,i));
end
nonM_ECov = cov(nonM_trainRet);
NPts = 100;
nonM_ERet = [nonM_trainRe1 nonM_trainRe2 nonM_trainRe3]';
% naiveMV model wiht non-mispricing values
[nonM_PRisk, nonM_PRoR, nonM_PWts] = naiveMV(nonM_ERet, nonM_ECov, NPts);
nonM_efficientRet = zeros(rows/2,NPts);
nonM_efficientRetAverage = zeros(rows/2,1);
efficientRet = zeros(rows/2,NPts);
efficientRetAverage = zeros(rows/2,1);
efficientRet1 = zeros(rows/2,NPts);
efficientRetAverage1 = zeros(rows/2,1);
% create mispricing values
Nrand = randperm(rows/2,200);
Nsize = size(Nrand);
for j = 1:Nsize
    return1(Nrand(j)) = 0;
    return2(Nrand(j)) = 0;
    return3(Nrand(j)) = 0;
end
% returns
misRe = [return1 return2 return3];
trainRe1 = mean(return1(1:rows/2));
trainRe2 = mean(return2(1:rows/2));
trainRe3 = mean(return3(1:rows/2));
trainRet = misRe(1:rows/2,:);
% for i = 1:3
%     trainRet(:,i) = trainRet(:,i) - mean(trainRet(:,i));
%     trainRet(:,i) = trainRet(:,i) / std(trainRet(:,i));
% end
ECov = cov(trainRet);
NPts = 10;
ERet = [trainRe1 trainRe2 trainRe3]';
% naiveMV model with mispricing values
[PRisk, PRoR, PWts] = naiveMV(ERet, ECov, NPts);

% Mac model -------------------------------
riskFree = 0.2;
sharpeEfficient = zeros(1, NPts);
for i = 1:NPts
    efficientRet = testRet * PWts';
end
for i=1:NPts
    sharpeEfficient(i) = (mean(efficientRet(:,i)) - riskFree)/std(efficientRet(:,i));
end
sharpeEfficientAverage = mean(sharpeEfficient);
% ERet1 = ERet - mean(ERet);
% ERet1 = ERet1 / std(ERet1);
ECov1 = ERet * ERet' * sharpeEfficientAverage + var(ERet).*eye(3);
[PRisk1, PRoR1, PWts1] = naiveMV(ERet, ECov1, NPts);
for i = 1:NPts
    nonM_efficientRet = testRet * nonM_PWts';
    efficientRet1 = testRet * PWts1';    
end
for i = 1:rows/2
    nonM_efficientRetAverage(i,1) = mean(nonM_efficientRet(i,:));
    efficientRetAverage(i,1) = mean(efficientRet(i,:));
    efficientRetAverage1(i,1) = mean(efficientRet1(i,:));
end
figure;
box on;
hold on;
grid on;
plot(efficientRetAverage,'g');
plot(efficientRetAverage1,'r');
plot(nonM_efficientRetAverage,'k')
legend("mispricing values","Mac model Non-mispricing","Non-mispricing");
title("2 different predict models");
xlabel("Days");
ylabel("Returns");