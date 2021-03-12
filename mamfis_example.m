close all;
% clear all;
clc;

% Create Mamdani fuzzy inference system
fis = mamfis('Name', "Network service", 'DefuzzificationMethod', "centroid");

% Configure inputs
fis = addInput(fis, [0 100], 'Name', "bandwith");
fis = addInput(fis, [0 100], 'Name', "loss");
fis = addInput(fis, [0 100], 'Name', "load");

% Configure outputs
fis = addOutput(fis, [0 1], 'Name', "quality");

% Setup Membreship functions
%
% Bandwith
fis = addMF(fis, "bandwith", "trimf", [-40.25 1 42.2500],       'Name', "low");
fis = addMF(fis, "bandwith", "trimf", [9.2500 50.5000 91.7500], 'Name', "normal");
fis = addMF(fis, "bandwith", "trimf", [58.7500 100 141.3000],   'Name', "high");

% Packet loss
fis = addMF(fis, "loss", "gaussmf", [3    5],   'Name', "low");
fis = addMF(fis, "loss", "gaussmf", [5   30],   'Name', "medium");
fis = addMF(fis, "loss", "gaussmf", [20 100],   'Name', "high");

% Server load
fis = addMF(fis, "load", "trimf", [-41.67   0   41.67], 'Name', "low");
fis = addMF(fis, "load", "trimf", [8.333   50   91.67], 'Name', "medium");
fis = addMF(fis, "load", "trimf", [58.33  100  141.7],  'Name', "high");

% Service quality
fis = addMF(fis, "quality", "trimf", [-0.41667  0   0.41667],   'Name', "low");
fis = addMF(fis, "quality", "trimf", [0.083333  0.5 0.91667],   'Name', "acceptable");
fis = addMF(fis, "quality", "trimf", [0.58333   1   1.4167],    'Name', "excellent");

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
bandwith = 10;
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

% Bandwith - Loss
nexttile; opt.InputIndex = [1 2]; opt.ReferenceInputs = [NaN NaN 50]; gensurf(fis, opt); view(90, 0);
nexttile; opt.InputIndex = [1 2]; opt.ReferenceInputs = [NaN NaN 50]; gensurf(fis, opt); view(00, 0);

% Loss - Load
nexttile; opt.InputIndex = [2 3]; opt.ReferenceInputs = [10 NaN NaN]; gensurf(fis, opt); view(90, 0);
nexttile; opt.InputIndex = [2 3]; opt.ReferenceInputs = [10 NaN NaN]; gensurf(fis, opt); view(00, 0);

% Bandwith - Load
nexttile; opt.InputIndex = [1 3]; opt.ReferenceInputs = [NaN 5 NaN];  gensurf(fis, opt); view(90, 0);
nexttile; opt.InputIndex = [1 3]; opt.ReferenceInputs = [NaN 5 NaN];  gensurf(fis, opt); view(00, 0);

