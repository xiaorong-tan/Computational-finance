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
Nrand = randperm(rows/2,50);
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
ERet = [trainRe1 trainRe2 trainRe3]';
% naiveMV model with mispricing values
[PRisk, PRoR, PWts] = naiveMV(ERet, ECov, NPts);

% Mac model -------------------------------
riskFree = 0.2;
sharpeMV = zeros(1, NPts);
for i = 1:NPts
    efficientRet = testRet * PWts';
end
for i=1:NPts
    sharpeMV(i) = (std(efficientRet(:,i))/(mean(efficientRet(:,i)) - riskFree))^2;
end
sharpeEfficientAverage = mean(sharpeMV);
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
plot(efficientRetAverage,'g','LineWidth',2);
plot(efficientRetAverage1,'r','LineWidth',2);
plot(nonM_efficientRetAverage,'k','LineWidth',2)
legend("MV model","MacKinlay & Pastor model","MV model with non-mispricing values",'Location','northwest');
title("MacKinlay & Pastor model",'FontSize',16);
xlabel("Days",'FontSize',14);
ylabel("Returns",'FontSize',14);

% error
MVerror = zeros(380,1);
Macerror = zeros(380,1);
trueValue = zeros(380,1);
for i = 1:380
    trueValue(i) = mean(testRet(i,:));
end
for i = 1:380
    MVerror(i) = efficientRetAverage(i) - trueValue(i);
    Macerror(i) = efficientRetAverage1(i) - trueValue(i);
end
figure;
boxplot([MVerror,Macerror],'Notch','on','Labels',{'Mean-variance model','MacKinlay & Pastor model'});
title("Prediction deviation of two models",'FontSize',16);
ylabel("Error",'FontSize',14);

% sharpe ratio
sharpeMV = zeros(1, NPts);
sharpeMac = zeros(1,NPts);
for i=1:NPts
    sharpeMV(i) = (mean(efficientRet(:,i)) - riskFree)/std(efficientRet(:,i));
    sharpeMac(i) = (mean(efficientRet1(:,i)) - riskFree)/std(efficientRet1(:,i));
end
sharpeMVAverage = mean(sharpeMV);
sharpeMacAverage = mean(sharpeMac);
colormap = autumn(NPts);
colormap2 = winter(NPts);
figure;
hold on;
grid on;
plot([1 NPts],[sharpeMVAverage sharpeMVAverage],'LineWidth',2,'Color',[0 0.7 0.2]);
plot([1 NPts],[sharpeMacAverage sharpeMacAverage],'LineWidth',2,'Color',[0 0.1 0.7]);
sharpeMV = fliplr(sharpeMV);
sharpeMac = fliplr(sharpeMac);
for i=1:NPts
    plot(i, sharpeMV(i), '.r', 'MarkerSize', 30, 'Color', colormap(i,:));
    plot(i, sharpeMac(i), 'ob', 'MarkerSize', 15, 'Color', colormap2(i,:));
end
sharpeMV = fliplr(sharpeMV);
sharpeMac = fliplr(sharpeMac);
xlabel('Portfolio', 'FontSize', 18);
ylabel('Ratio', 'FontSize', 18);
title(strcat('Sharpe Ratio - Risk Free:', int2str(riskFree*100) ,'%' ), 'FontSize', 18);
legend('Mean-variance Avg.', 'MacKinlay & Pastor model Avg.', 'Mean-variance model','MacKinlay & Pastor model');