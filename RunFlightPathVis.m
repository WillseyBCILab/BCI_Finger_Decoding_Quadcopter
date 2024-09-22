figure

t = tiledlayout(2,2);

tt = 1:15001;
nexttile
PlotFlightPath(tt)
set(gca,'tickdir','out')

nexttile
tt = 15001:37501;
PlotFlightPath(tt)
set(gca,'tickdir','out')

nexttile
tt = 37501:55001;
PlotFlightPath(tt)
set(gca,'tickdir','out')

nexttile
tt = 55001:81601;
PlotFlightPath(tt)
set(gca,'tickdir','out')

t.TileSpacing = 'compact';
t.Padding = 'compact';

figure
PlotFlightPath
axis(gca,'tight')
set(gca,'Position',[.02 .02 1.2*[0.7750 0.8150]])