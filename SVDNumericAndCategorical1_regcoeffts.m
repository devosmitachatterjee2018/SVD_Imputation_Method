clc;
close all;
clear;
%%
opts = detectImportOptions('vehicleData_new.csv','NumHeaderLines',0);
X_true = readtable('vehicleData_new.csv',opts);
%%
rng(2);
p = 2;
X_notimputed = X_true{:,:};
matrix_size = numel(X_notimputed);
missingNumber = round(p*0.1*matrix_size);
X_notimputed(randperm(matrix_size, missingNumber))= missing;
%%
NaNed = X_notimputed;
X_imputed = ImputerKeep(NaNed);
%%
y_imputed = X_imputed(:,1);
x_imputed = X_imputed(:,2:end);

x_imputed = [ones(size(y_imputed)) x_imputed];
b_imputed = regress(y_imputed,x_imputed)
%%
y_true = X_true(:,1);
x_true = X_true(:,2:end);

x_true = [ones(size(y_true{:,:})) x_true{:,:}];
b_true = regress(y_true{:,:},x_true)
%%
y_notimputed = X_notimputed(:,1);
x_notimputed = X_notimputed(:,2:end);

x_notimputed = [ones(size(y_notimputed)) x_notimputed];
b_notimputed = regress(y_notimputed,x_notimputed)
%%
plot(1:size(X_true,2),b_imputed,'r--',1:size(X_true,2),b_notimputed,'g*',1:size(X_true,2),b_true,'b')
title({'SVD Imputer Method on Numeric and Categorical Data';'846 Rows, 19 Columns';'18 Numeric Features, 1 Text Feature'});
legend({'True','Nonimputed','Imputed'},'Location','best')
xlabel('Features')
ylabel('Regression Coefficients')
