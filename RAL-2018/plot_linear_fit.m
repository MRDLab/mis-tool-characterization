function [ Table ] = plot_linear_fit(key,conf,data,Y_var,X_var,depVar,est_method,Table)
% Plot linear fit of the data, and calculate some metrics in a table

% Set up colors for plotting
exp0Col = [215,25,28]*(1/255);
exp1Col = [253,174,97]*(1/255);
exp2Col = [171,221,164]*(1/255);
exp3Col = [43,131,186]*(1/255);

%

Y=data(round(end/8):end,Y_var,key.r.filt)*conf.unitFactor(depVar);
X=data(round(end/8):end,X_var,key.r.filt)*conf.permscale{est_method};

[Spearman_RHO] = corr(X,Y,'Type','Spearman');
[Pearson_R] = corr(X,Y,'Type','pearson');

%fprintf('Spearman_Rho=%f,   Pearsons_R=%f\n',Spearman_RHO,Pearson_R);

fh=figure(est_method+5*depVar);clf;

plot(X,Y,'.','Color',exp0Col);
hold on;
ylabel(conf.ylabstime{depVar});
xlabel(strcat(conf.names{est_method},conf.permunits{est_method}));

x = [ones(length(X),1) X];
b = x\Y;
yCalc = x*b;
plot(X,yCalc,'-','Color','k')
%legend('Raw Data','Linear Fit','Location','SouthEast');
legend({'Raw Data','Linear Fit'},'Position',[0.71,1.28,0,0]);

allAbsolute_err = yCalc - Y;
BoxPlotN = numel(X);
out_test = Y;

[ Table ] = compileMetrics( Table, allAbsolute_err, out_test, conf.percentile, est_method, depVar, BoxPlotN, Spearman_RHO, Pearson_R );

if conf.save_figs
    saveFigLaTeX(['Figures/Linear_' conf.dimBrief{depVar} '_' num2str(est_method)],fh,conf.figSize(1)*1.99/3,conf.figSize(2), false);
end

end

