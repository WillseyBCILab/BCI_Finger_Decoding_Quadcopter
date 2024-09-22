function tuningAnalysesFunc(sDat)

    %%
    if isfield(sDat,'plottingWindow')
        plottingWindow = sDat.plottingWindow;
        binWidth = sDat.binWidth;
    else
        plottingWindow = [-300 250];
        binWidth = 0.01;
    end
    
    if isfield(sDat,'analysisWindow')
        analysisWindow = sDat.analysisWindow;
    else
        analysisWindow = [10 65];
    end
    
    if isfield(sDat,'gaussSmoothWidth')
        gaussSmoothWidth = sDat.gaussSmoothWidth;
    else
        gaussSmoothWidth = 6;
    end
    
    if isfield(sDat,'rasterMax')
        rasterMax = sDat.rasterMax;
    else
        rasterMax = 2;
    end
    
    if isfield(sDat,'plotRasters')
        plotRasters = sDat.plotRasters;
    else
        plotRasters = true;
    end
    
    %%
    %classification across all classes
    sortedSetIdx = horzcat(sDat.movementSets{:});
    sortedSetIdx = [sortedSetIdx, sDat.doNothingCode];

    [ C, L ] = simpleClassify( sDat.features, sDat.movementCodes, sDat.goTimes+analysisWindow(1), sDat.movementNames, ...
        analysisWindow(2)-analysisWindow(1), 1, 0, true,sortedSetIdx  ); 
    
    boxColors = [173,150,61;
    119,122,205;
    91,169,101;
    197,90,159;
    202,94,74]/255;
    boxColors = [boxColors; 0.8*[0.2667    0.8000    0.5333]; 0.8*[0    0.5333    0.8000]; lines(5)];

    currentIdx = 0;
    currentColor = 1;
    for c=1:length(sDat.movementSets)
        newIdx = currentIdx + (1:length(sDat.movementSets{c}))';
        rectangle('Position',[newIdx(1)-0.5, newIdx(1)-0.5,length(newIdx), length(newIdx)],...
            'LineWidth',5,'EdgeColor',boxColors(currentColor,:));
        currentIdx = currentIdx + length(sDat.movementSets{c});
        currentColor = currentColor + 1;
    end

    set(gcf,'Units','normalized','Position',[0.3171    0.0458    0.6847    0.8469]);    
    if size(C,1)>80
        set(gca,'FontSize',5);
    elseif size(C,1)>60
        set(gca,'FontSize',7);
    end
    set(gca, 'YDir','reverse')
    caxis([0, 1])
return