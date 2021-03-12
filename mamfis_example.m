close all;
clear all;
clc;

% Create Mamdani fuzzy inference system
fis = mamfis('Name', "Network service", 'DefuzzificationMethod', "centroid");

% Configure inputs
fis = addInput(fis, [0 100], 'Name', "bandwith");
fis = addInput(fis, [0 100], 'Name', "loss");
fis = addInput(fis, [0 100], 'Name', "load");

% Configure outputs
fis = addOutput(fis, [0 100], 'Name', "quality");

% Setup Membreship functions
%
% Bandwith
fis = addMF(fis, "bandwith", "trimf", [ 0   2.5   5],   'Name', "low");
fis = addMF(fis, "bandwith", "trimf", [ 5  12.5  20],   'Name', "normal");
fis = addMF(fis, "bandwith", "trimf", [20  60   100],   'Name', "high");

% Packet loss
fis = addMF(fis, "loss", "trimf", [ 0  5  10],   'Name', "low");
fis = addMF(fis, "loss", "trimf", [10 15  20],   'Name', "medium");
fis = addMF(fis, "loss", "trimf", [20 60 100],   'Name', "high");

% Server load
fis = addMF(fis, "load", "trimf", [ 0   20   40], 'Name', "low");
fis = addMF(fis, "load", "trimf", [40   60   80], 'Name', "medium");
fis = addMF(fis, "load", "trimf", [80   90  100], 'Name', "high");

% Service quality
fis = addMF(fis, "quality", "trimf", [ 0  20  40],  'Name', "low");
fis = addMF(fis, "quality", "trimf", [40  60  80],  'Name', "acceptable");
fis = addMF(fis, "quality", "trimf", [80  90 100],  'Name', "excellent");

% Add rules
rule1 = "bandwith~=low & loss==low & load~=high => quality=excellent (1)";
rule2 = "bandwith==normal & loss==low & load==medium => quality=excellent (1)";
rule3 = "bandwith==normal & loss~=high & load~=high => quality=acceptable (1)";
rule4 = "bandwith==high & loss==medium & load==medium => quality=acceptable (1)";
rule5 = "bandwith~=high & loss==high & load==high => quality=low (1)";
rule6 = "bandwith==low & loss~=low & load~=low => quality=low (1)";

rules = [rule1 rule2 rule3 rule4 rule5 rule6];
fis = addRule(fis, rules);

% Evaluate fuzzy logic system
bandwith = 1;
loss = 5;
load = 40;

quality = evalfis(fis, [bandwith loss load]);
fprintf("Service quality: %f\n", quality);

% Plot membership functions
fig_mf = figure('name', "Membership Functions");
tiledlayout(4, 1);
nexttile; plotmf(fis, 'input', 1);
nexttile; plotmf(fis, 'input', 2);
nexttile; plotmf(fis, 'input', 3);
nexttile; plotmf(fis, 'output', 1);

% Plot system
fig_sys = figure('name', "System Architecture");
plotfis(fis);

% Generate output surfaces
fig_surf = figure('name', "Output Surface");
tiledlayout(3, 2);
opt = gensurfOptions;

% Loss - Load
nexttile; opt.InputIndex = [2 3]; opt.ReferenceInputs = [bandwith NaN NaN]; gensurf(fis, opt); view(90, 0);
title(sprintf("Bandwith: %.2f Mbps\n", bandwith));
nexttile; opt.InputIndex = [2 3]; opt.ReferenceInputs = [bandwith NaN NaN]; gensurf(fis, opt); view(00, 0);

% Load - Bandwith
nexttile; opt.InputIndex = [1 3]; opt.ReferenceInputs = [NaN loss NaN];  gensurf(fis, opt); view(90, 0);
title(sprintf("Loss: %.2f %%\n", loss));
nexttile; opt.InputIndex = [1 3]; opt.ReferenceInputs = [NaN loss NaN];  gensurf(fis, opt); view(00, 0);

% Bandwith - Loss
nexttile; opt.InputIndex = [1 2]; opt.ReferenceInputs = [NaN NaN load]; gensurf(fis, opt); view(90, 0);
title(sprintf("Load: %.2f %%\n", load));
nexttile; opt.InputIndex = [1 2]; opt.ReferenceInputs = [NaN NaN load]; gensurf(fis, opt); view(00, 0);
