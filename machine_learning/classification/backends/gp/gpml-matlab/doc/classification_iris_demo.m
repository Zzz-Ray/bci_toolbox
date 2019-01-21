%% Okba BEKHELIFI - 20-01-2019
% <okba.bekhelifi@univ-usto.dz>
% Gaussian Process classification on iris dataset
%% binary
tic;
load iris_dataset
X = irisInputs';
[Y, ~] = find(irisTargets);
proptrain = .5;

id_bin = Y==1 | Y==2;
x = X(id_bin,:);
y = Y(id_bin);
y(y==2) = -1;
n = size(x, 1);
% split data in two groups
ntrain = round(n*proptrain);
ntest = n - ntrain;
rp = randperm(n);
trainset = rp(1:ntrain);
testset  = rp(ntrain+1:end);
x_train = x(trainset,:);
y_train = y(trainset);
x_test = x(testset,:);
y_test = y(testset);
%% Gaussian Process Model: Training, hyperparameter tuning, prediction
% init
meanFunc = @meanZero;

% covFunc = @covSEard;
covFunc = @covSEiso;

likFunc = @likLogistic;
% likFunc = @likUni;

% infFunc = @infLaplace;
% infFunc = @infKL;
% infFunc = @infVB;

ell = 1.0;
sf = 1.0;
% hyp.mean = 0;
hyp.mean = [];
% hyp.cov = log([ell ell ell ell sf]); % when using cov with ard, the number of cov params must be equal to D (D=dimension of examples, size(X,2))
hyp.cov  = log([ell sf]);
% Training
hyp = minimize(hyp, @gp, -40, infFunc, meanFunc, covFunc, likFunc, x_train, y_train);
[nl,dnl] = gp(hyp, infFunc, meanFunc, covFunc, likFunc, x_train, y_train);
% Prediction
% when using probs prediction by MAP (p45 GPML)
[ym ys fm fs] = gp(hyp, infFunc, meanFunc, covFunc, likFunc, x_train, y_train, x_test);
re = 1./(1+exp(-fm));
er = [re 1-re y_test];
pb = er(:,1:2);
[v,i] = max(pb,[], 2);
i(i==2) = -1;
sum(i==y_test)/50
% predictive distribution
[ymu ys2 fmu fs2 lp] = gp(hyp, infFunc, meanFunc, covFunc, likFunc, x_train, y_train, x_test, y_test);
probs = [exp(lp), 1-exp(lp), y_test];
yy = ones(50,1);
yy(ymu<0.5) = -1;
acc = sum(yy==y_test)/50
nl
