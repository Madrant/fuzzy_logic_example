close all;
clear all;
clc;

% Bandwith
bw_l = [ 0  0   5  10];
bw_m = [ 5 10  20  30];
bw_h = [20 50 100 100];

% Packet loss
pl_l = [ 0  0  5 10];
pl_m = [ 5 10 15 20];
pl_h = [10 30 100 100];

% Server load
sl_l = [ 0   0  20  40];
sl_m = [30  50  70  80];
sl_h = [70  90 100 100];

% Service quality
sq_l = [ 0   0  20  40];
sq_m = [30  50  60  75];
sq_h = [70  90 100 100];

% Plot membership functions
plot_trapmf(cat(3, [bw_l; bw_m; bw_h], [pl_l; pl_m; pl_h], [sl_l; sl_m; sl_h], [sq_l; sq_m; sq_h]));

% Calculate alpha-levels
levels = [1 0.5 0];

% Bandwith
fprintf("Alpha levels:\n");

fprintf("Bandwith:\n");
print_alpha_level("  Low   ", bw_l, levels); 
print_alpha_level("  Medium", bw_m, levels); 
print_alpha_level("  High  ", bw_h, levels); 

% Calculate membership functions:
bandwith = 20;
loss = 5;
load = 60;

fprintf("Bandwith: %.2f Packet loss: %.2f Server load: %.2f\n", bandwith, loss, load);

% Bandwith:
bw_mf = [ mf_trapmf(bandwith, bw_l) mf_trapmf(bandwith, bw_m) mf_trapmf(bandwith, bw_h) ];
fprintf("MF Bandwith:   \tLow: %.2f\t Medium: %.2f\t High: %.2f\n", bw_mf(1), bw_mf(2), bw_mf(3));

% Packet loss
pl_mf = [ mf_trapmf(loss, pl_l) mf_trapmf(loss, pl_m) mf_trapmf(loss, pl_h) ];
fprintf("MF Packet loss:\tLow: %.2f\t Medium: %.2f\t High: %.2f\n", pl_mf(1), pl_mf(2), pl_mf(3));

% Server load
sl_mf = [ mf_trapmf(load, sl_l) mf_trapmf(load, sl_m) mf_trapmf(load, sl_h) ];
fprintf("MF Server load:\tLow: %.2f\t Medium: %.2f\t High: %.2f\n", sl_mf(1), sl_mf(2), sl_mf(3));

% Some stuff to simplify rules
bw_low = bw_mf(1);
bw_med = bw_mf(2);
bw_high = bw_mf(3);

pl_low = pl_mf(1);
pl_med = pl_mf(2);
pl_high = pl_mf(3);

sl_low = sl_mf(1);
sl_med = sl_mf(2);
sl_high = sl_mf(3);

% Define fuzzy logic rules (Knowledge base)
%
% "bandwith==high & loss==low & load~=high => quality=high (1)";
rule_high1 = fuzzy_rule(bw_high, pl_low, 1 - sl_high);

% "bandwith~=low & loss==low & load~=high => quality=high (1)";
rule_high2 = fuzzy_rule(1 - bw_low, pl_low, 1 - sl_high);

% "bandwith~=high & loss~=low & load~=high => quality=medium (1)";
rule_med1 = fuzzy_rule(1 - bw_high, 1 - pl_low, 1 - sl_high);

% "bandwith~=low & loss==low & load==high => quality=medium (1)";
rule_med2 = fuzzy_rule(1 - bw_low, pl_low, sl_high);

% "bandwith==low & loss==low & load==high => quality=medium (1)";
rule_med3 = fuzzy_rule(bw_low, pl_low, sl_high);

% "bandwith==high & loss~=high & load~=high => quality=medium (1)";
rule_med4 = fuzzy_rule(bw_high, 1 - pl_high, 1 - sl_high);

% "bandwith==low & loss~=high & load~=high => quality=medium (1)";
rule_med5 = fuzzy_rule(bw_low, 1 - pl_high, 1 - sl_high);

% "bandwith==high & loss==high & load~=high => quality=medium (1)";
rule_med6 = fuzzy_rule(bw_high, pl_high, 1 - sl_high);

% "bandwith==high & loss==high & load==high => quality=low (1)";
rule_low1 = fuzzy_rule(bw_high, pl_high, sl_high);

% "bandwith~=high & loss==high & load~=high => quality=low (1)";
rule_low2 = fuzzy_rule(1 - bw_high, pl_high, 1 - sl_high);

% "bandwith~=high & loss~=low & load==high => quality=low (1)";
rule_low3 = fuzzy_rule(1 - bw_high, 1 - pl_low, sl_high);

% "bandwith==high & loss~=high & load==high => quality=low (1)";
rule_low4 = fuzzy_rule(bw_high, 1- pl_high, sl_high);

rule_high = max([rule_high1 rule_high2]);
rule_med = max([rule_med1 rule_med2 rule_med3 rule_med4 rule_med5 rule_med6]);
rule_low = max([rule_low1 rule_low2 rule_low3 rule_low4]);

rules = [rule_low rule_med rule_high ];
fprintf("Service quality: Low: %.2f Medium: %.2f High: %.2f\n", rule_low, rule_med, rule_high);

% Display result
names = ["Low" "Medium" "High"];
[val, index] = max(rules);

fprintf("Service quality: %s\n", names(index));

% Calculate alpha-level boundaries
function [q1, q2] = alpha_level_trapmf(trapmf, alpha)
    q_l_0 = trapmf(1);
    q_l_1 = trapmf(2);
    q_h_1 = trapmf(3);
    q_h_0 = trapmf(4);

    q1 = q_l_0 + (q_l_1 - q_l_0) * alpha;
    q2 = q_h_0 - (q_h_0 - q_h_1) * alpha;
end

function print_alpha_level(term_name, mf, alpha)
    for l = 1:length(alpha)
        level = alpha(l);
        [q1, q2] = alpha_level_trapmf(mf, level);
        fprintf("%s: %.2f: [ %3.2f %3.2f]\t", term_name, level, q1, q2);
    end

    fprintf("\n");
end

% Calculate membership function's value for trapmf
function mf = mf_trapmf(q, trapmf)
    q_l_0 = trapmf(1);
    q_l_1 = trapmf(2);
    q_h_1 = trapmf(3);
    q_h_0 = trapmf(4);

    mf = 0;

    if (q >= q_l_0) && (q < q_l_1)
        mf = (q - q_l_0) / (q_l_1 - q_l_0);
    end

    if (q >= q_l_1) && (q <= q_h_1)
        mf = 1;
    end

    if (q > q_h_1) && (q <= q_h_0)
        mf = (q_h_0 - q) / (q_h_0 - q_h_1);
    end
end

% Process fuzzy logic rules
function result = fuzzy_rule(a, b, c)
    result = min([a b c]);
end

% Plot trapezoidal membership functions
function plot_trapmf(mf_array)
    num_pages = size(mf_array, 3);

    figure('name', "Membership Functions");
    tiledlayout(num_pages, 1);

    % Each page is a N х 4 trapezoidal membership function
    for p = 1:num_pages
        nexttile;
        hold on;

        num_rows = size(mf_array(:,:,p));

        for row = 1:num_rows
            plot(mf_array(row,:,p), [0 1 1 0]);
        end

        hold off;
    end
end
