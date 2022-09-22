%% Init Workspace
close all; clear; clc

addpath('functions')

% Init plot object properties
set(0, 'DefaultLineLineWidth', 1.2, 'DefaultAxesFontSize', 12, 'DefaultTextFontSize', 20, 'DefaultTextFontName', 'Calibri')

%% Load file
load("example_fan_control.mat");

%% Make preprocessing
% TODO: change the parameters relative to Ts
[u_mean, y_mean, idx] = preprocessData(data);

%% Identify system parameters of the specified order 
Ts = 0.01;
idtf = recursiveLeastSquares(u_mean, y_mean, Ts, ...
    1, ... % Number of zeros, 
    2, ... % Number of poles, 
    'PlotConv', true);
