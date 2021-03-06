clear all;
clc;
load input_noCov.mat;
load output_south.mat;
initAvg = mean(X);
X = X - repmat(initAvg, size(X,1), 1);
initRan = std(X);
X = X ./ repmat(initRan, size(X,1), 1);
 
[X, U, error, ~] = pca(X,0.9999);
%%%Normalizing after pca%%%%
ran1 = 2*std(X);
X = X ./ repmat(ran1, size(X,1), 1);

origX = X;
origY = 100*y;
assert(size(origX,1) == size(origY,1), 'Dimensions of input and outputs are not matching');

origX = origX';
origY = origY';
hid = 200;
i = 1;

for predictionYear = 2005:2012,
    
    Xtest   = origX (:, end - ( (2012-predictionYear)*122+121 ) : end - (2012-predictionYear)*122);
    ytest   = origY (:, end - ( (2012-predictionYear)*122+121 ) : end - (2012-predictionYear)*122);
    errors(i,1) = predictionYear;
    
%     curYearX = origX( end - ( ( (2012+prevYears)-predictionYear )*122+121 ) : end - ( (2012-predictionYear)*122+122 ), : );
%     curYearY = origY( end - ( ( (2012+prevYears)-predictionYear )*122+121 ) :end - ( (2012-predictionYear)*122+122 ), : );
  
    curYearX = origX(:, 1 : end - ( (2012-predictionYear)*122+122 ));
    curYearY = origY(:, 1 : end - ( (2012-predictionYear)*122+122 ));
    
    for exp = 1:1,
        disp(['predicting ' num2str(predictionYear) ' experiment ' num2str(exp)]);
        net = feedforwardnet(hid);
        net = configure(net,curYearX,curYearY);
        net.trainFcn = 'trainscg';
%         net.trainFcn = 'trainlm';
        net.layers{1}.transferFcn = 'tansig';
        net.layers{2}.transferFcn = 'purelin';
        net.trainParam.showWindow=0; 
        net.Efficiency.memoryReduction=20;
        net = train(net,curYearX,curYearY,'useParallel','yes','showResources','no');
        predicted = net(Xtest);
        errors(i,exp+1) = mean( mean( abs((predicted - ytest) * 100 ./ mean(origY)) ) );
    end
    i = i + 1;
end
disp('mean error');
mean(mean(errors(:,2:end)))
