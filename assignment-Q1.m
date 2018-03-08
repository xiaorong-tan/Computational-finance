x = linspace(0,0.1,10);
y = linspace(0,0.0025,10);
xx = zeros(10,1);
yy = zeros(10,1);
for i = 1:10
    xx(i) = 0.0025;
    yy(i) = 0.1;
end
box on;
hold on;
plot(0.0025,0.1,'or','MarkerSize',8);
plot(xx,x,'k--');
plot(y,yy,'k--');
axis([0 0.003 0 0.2]);
grid on;
xlabel("Risk");
ylabel("Return");
title("Efficient Frontier",'FontSize',16);