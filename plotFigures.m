rng("default")
clear, clc, close all

win2s = [00, 39]; % 2 sec windows
win150ms = [10, 12]; % 150 ms windows 

RunAnalysis(win2s)
RunAnalysis(win150ms)