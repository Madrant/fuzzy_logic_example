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
fis = addMF(fis, "bandwith", "trapmf", [ 0  0   5  10],   'Name', "low");
fis = addMF(fis, "bandwith", "trapmf", [ 5 10  20  30],   'Name', "medium");
fis = addMF(fis, "bandwith", "trapmf", [20 50 100 100],   'Name', "high");

% Packet loss
fis = addMF(fis, "loss", "trapmf", [ 0  0  5 10],   'Name', "low");
fis = addMF(fis, "loss", "trapmf", [ 5 10 15 20],   'Name', "medium");
fis = addMF(fis, "loss", "trapmf", [10 30 100 100],   'Name', "high");

% Server load
fis = addMF(fis, "load", "trapmf", [ 0   0  20  40], 'Name', "low");
fis = addMF(fis, "load", "trapmf", [30  50  70  80], 'Name', "medium");
fis = addMF(fis, "load", "trapmf", [70  90 100 100], 'Name', "high");

% Service quality
fis = addMF(fis, "quality", "trapmf", [ 0   0  20  40],  'Name', "low");
fis = addMF(fis, "quality", "trapmf", [30  50  60  80],  'Name', "medium");
fis = addMF(fis, "quality", "trapmf", [70  90 100 100],  'Name', "high");

% Add rules
rules = [ "" ];
rules(:, end + 1) = "bandwith==high & loss==low & load~=high => quality=high (1)";
rules(:, end + 1) = "bandwith~=low & loss==low & load~=high => quality=high (1)";

rules(:, end + 1) = "bandwith~=high & loss~=low & load~=high => quality=medium (1)";
rules(:, end + 1) = "bandwith~=low & loss==low & load==high => quality=medium (1)";
rules(:, end + 1) = "bandwith==low & loss==low & load==high => quality=medium (1)";
rules(:, end + 1) = "bandwith==high & loss~=high & load~=high => quality=medium (1)";
rules(:, end + 1) = "bandwith==low & loss~=high & load~=high => quality=medium (1)";
rules(:, end + 1) = "bandwith==high & loss==high & load~=high => quality=medium (1)";

rules(:, end + 1) = "bandwith==high & loss==high & load==high => quality=low (1)";
rules(:, end + 1) = "bandwith~=high & loss==high & load~=high => quality=low (1)";
rules(:, end + 1) = "bandwith~=high & loss~=low & load==high => quality=low (1)";
rules(:, end + 1) = "bandwith==high & loss~=high & load==high => quality=low (1)";

fis = addRule(fis, rules);

% Evaluate fuzzy logic system
test_all_values = true;

if test_all_values
for bandwith = 0:10:100
    for loss = 0:10:100
        for load = 0:10:100
            quality = evalfis(fis, [bandwith loss load]);

            % Fuzzy output is set to mean value:
            % no rules fired for given values
            if quality == 50.0 % Edit this value for the own case
                fprintf("Bandwith: %.2f Packet loss: %.2f Load: %.2f Service quality: %.2f\n", bandwith, loss, load, quality);
                error("No rules fired");
            end
        end % load
    end % loss
end % bandwith
end

% Test fuzzy system for predefined values
bandwith = 20;
loss = 5;
load = 40;

quality = evalfis(fis, [bandwith loss load]);
fprintf("Bandwith: %.2f Packet loss: %.2f Load: %.2f Service quality: %.2f\n", bandwith, loss, load, quality);

waitforbuttonpress;

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
