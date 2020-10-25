clc;
close all;
clear;
%%
opts = detectImportOptions('AutoData_new_full.csv','NumHeaderLines',0);
X_true = readtable('AutoData_new_full.csv',opts);
%%
per = {};
NRSME = {};
%%
for p = 1:1:5 
    rng(2);
    X = X_true{:,:};
    matrix_size = numel(X);
    missingNumber = round(p*0.1*matrix_size);
    X(randperm(matrix_size, missingNumber))= missing;
    per{p} = round((length(find(ismissing(X) == 1))/numel(X))*100);

    X_imputed = ImputerKeep(X);
    %%
    % NRSME
    NRSME{p} = mean((X_true{:,:} - X_imputed).^2)/var(X_true{:,:});    
end
%%
plot(1:1:5,str2double(string(NRSME)),'r*-');
xlim([1 5])
xticks([1 2 3 4 5])
xticklabels({'10%','20%','30%','40%','50%'})
title({'SVD Imputer Method on Numeric and Categorical Data';'205 Rows, 25 Columns';'15 Numeric Features, 10 Text Feature'})
xlabel('Missing Percentage')
ylabel('NRSME')
