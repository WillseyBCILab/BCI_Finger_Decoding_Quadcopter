clc, clear

load statsMatlab.mat

disp('Acquisition Times: 2- vs 4-DOF')
[h,p,ci,stats] = ttest2(AcqTimes_4DOF,AcqTimes_2DOF,'tail','both')

disp('Acquisition Times: 2D2T vs 4D2T')
[h,p,ci,stats] = ttest2(AcqTimes_4D2T,AcqTimes_2D2T,'tail','both')

disp('Acquisition Times: 1 Finger vs 2 Finger')
[h,p,ci,stats] = ttest2(AcqTimes_1Fing,AcqTimes_2Fing,'tail','both')

disp('Rate: 1 Finger vs 2 Finger')
[h,p,ci,stats] = ttest2(Rate_2Fing,Rate_1Fing,'tail','both')

disp('Dimensionality: 2x2-DOF vs 4-DOF')
[h,p,ci,stats] = ttest2(Dim4D,Times2_Dim2D,'tail','both')