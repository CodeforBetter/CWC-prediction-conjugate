clear all;
clc;
load input_noCov.mat;
load output_south.mat;
initAvg = mean(X);
X = X - repmat(initAvg, size(X,1), 1);
initRan = sqrt( mean(X.^2) );
X = X ./ repmat(initRan, size(X,1), 1);
[X, U, error, ~] = pca(X,0.9999);
%%%Normalizing after pca%%%%
ran1 = 2*sqrt( var(X) );
X = X ./ repmat(ran1, size(X,1), 1);

y = 100 * y ;
assert(size(X,1) == size(y,1), 'Dimensions of input and outputs are not matching');

origX = X;
origY = y;
meanValues = mean(origY);

%%%Library part
input_layer_size = size(X,2);
hidden_layer_size = 100;
num_labels = size(y,2);
lambda = 0.1;

startYear = 2005;
endYear = 2012;
prevYears = 110;

for i = 1:(endYear-startYear)+1,

    predictionYear = startYear + i - 1;
    errors(i,1) = predictionYear;

    %%%%Dividing into validation set, train set and test set%%%%
    Xtest   = origX( end - ( (2012-predictionYear)*122+121 ) : end - (2012-predictionYear)*122 , :);
    ytest   = origY( end - ( (2012-predictionYear)*122+121 ) : end - (2012-predictionYear)*122 , : );

%     curYearX = origX( end - ( ( (2012+prevYears)-predictionYear )*122+121 ) : end - ( (2012-predictionYear)*122+122 ), : );
%     curYearY = origY( end - ( ( (2012+prevYears)-predictionYear )*122+121 ) :end - ( (2012-predictionYear)*122+122 ), : );
  
    curYearX = origX( 1 : end - ( (2012-predictionYear)*122+122 ), : );
    curYearY = origY( 1 : end - ( (2012-predictionYear)*122+122 ), : );
    
    
    for exp = 1:2,
        
        randpos = randperm( size(curYearX,1) );
        curYearX = curYearX(randpos,:);   curYearY(randpos,:);
        
        disp( ['Predicting year ' num2str(predictionYear) ' experiment number ' num2str(exp)] );

        costFunc = @(p) costFunction(p, ...
                                           input_layer_size, ...
                                           hidden_layer_size, ...
                                           num_labels, curYearX, curYearY, lambda);

        valcostFunc = @(p) costFunction(p, ...
                                           input_layer_size, ...
                                           hidden_layer_size, ...
                                           num_labels, Xtest, ytest, 0);

        initial_Theta1 = [ zeros(hidden_layer_size,1) ( rand( hidden_layer_size, input_layer_size ) - 0.5 ) * 2 * sqrt(6 / (hidden_layer_size+input_layer_size)) ];
        initial_Theta2 = [ zeros(num_labels,1) ( rand( num_labels, hidden_layer_size ) - 0.5 ) * 20 * sqrt(6 / (hidden_layer_size+num_labels)) ];
        nn_params = [ initial_Theta1(:); initial_Theta2(:) ] ;

        % Now, costFunction is a function that takes in only one argument (the
        % neural network parameters)
        options = optimset('MaxIter', 150);
%         pause;
        [nn_params, ~] = fmincg(costFunc, nn_params, options, valcostFunc, 0, 1);
%         pause;
        % Obtain Theta1 and Theta2 back from nn_params
        nn.Theta1 = reshape(nn_params(1:hidden_layer_size * (input_layer_size + 1)), ...
                         hidden_layer_size, (input_layer_size + 1));

        nn.Theta2 = reshape(nn_params((1 + (hidden_layer_size * (input_layer_size + 1))):end), ...
                         num_labels, (hidden_layer_size + 1));

%         nn.Theta1(1:5,1:8)
        a2 = tanh_opt([ones(size(Xtest,1),1) Xtest] * nn.Theta1');
        a3 = [ones(size(Xtest,1),1) a2] * nn.Theta2';
%         a3
%         ytest
%         mean( sum((a3-ytest).^2, 2 ) )/2
        mean(a2)

        [trainerror, errors(i,2*exp), abstrainerror, errors(i,2*exp+1)] = feedForward_superVised(nn,curYearX,curYearY,Xtest,ytest,meanValues);

        disp('rms train error');
        disp(trainerror);
        
        disp('rms test error');
        disp(errors(i,2*exp));
        
        disp('abs train error');
        disp(abstrainerror);
        
        disp('abs test error');
        disp(errors(i,2*exp+1));
        
    end
end

csvwrite(['BasicNNfrom' num2str(startYear) 'to' num2str(endYear) 'hid' num2str(hidden_layer_size) 'lambda' num2str(lambda) '.csv'], errors);
disp('rms error');
disp(mean(mean(errors(:,2:2:end))))
disp('abs error');
disp(mean(mean(errors(:,3:2:end))))
