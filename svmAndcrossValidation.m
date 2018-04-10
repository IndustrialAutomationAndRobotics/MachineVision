clear all
clc

load fisheriris
groups = ismember(species,'virginica');

k = 10;

cvFolds = crossvalind('Kfold', groups, k);
cp = classperf(groups);

for i = 1:k
    testIdx = (cvFolds == i);
    trainIdx = ~testIdx;
    
    svmModel = svmtrain(meas(trainIdx,:), groups(trainIdx), ...
        'Autoscale',true,'Showplot',false,'Method','QP', ...
        'BoxConstraint',2e-1, 'Kernel_Function','rbf','RBF_Sigma',1);
    
    pred = svmclassify(svmModel, meas(testIdx,:), 'Showplot', false);
    
    cp = classperf(cp, pred, testIdx);
    
end

cp.CorrectRate

cp.CountingMatrix