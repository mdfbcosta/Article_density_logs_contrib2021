close all
clear all
clc

% =========================================================================
%                               DASHBOARD
% -------------------------------------------------------------------------
% This is your dashboard. Here you can define the steps for generating
% the graphs to analyze the suggested hypotheses through the setting of
% a configuration vector, the v_setting.
% =========================================================================

% -------------------------------------------------------------------------
% REFERENCE WELL (For estimative of the parameters)
% It rename the wells as dado1.las, dado2.las, dado3.las, etc. 
pwell = 7;

% Choose the equation for Shale volume - Vsh.
% 1 --> for Larionov Tertiary rock
% 2 --> for Larionov Older rock
% 3 --> for Steiber
% 4 --> for Clavier
ivsh = 1;

% MENSAGEM SOBRE O QUE O CÓDIGO FAZ ---------------------------------------
uiwait (msgbox({'This code makes three estimates of "bulk density" in three different situations:',' ',...
    '1- with SPIKE CORRECTION;',...
    '2- With ORIGINAL WELL DATA (raw data);',...
    '3- With SPIKE AND CALIPER CORRECTION.',' ',...
    'OBS.: The pictures will be automatically saved to the main directory.'},'Code Information'));

v_setting = [ivsh pwell];
[parametros] = actions_exe_3 (v_setting);
fileID = fopen('para_nl.txt','w');
fprintf(fileID,'%12.8f %12.8f %12.8f\n',parametros.nl');
fclose(fileID);
fileID = fopen('para_li.txt','w');
fprintf(fileID,'%12.8f %12.8f %12.8f\n',parametros.li');
fclose(fileID);
fileID = fopen('para_ga.txt','w');
fprintf(fileID,'%12.8f %12.8f %12.8f\n',parametros.ga');
fclose(fileID);

%% Rodar apenas para testar em outros poços.
answer = questdlg('Do you want to use the calculated parameters now to estimate other wells?', ...
    'Checkbox', ...
    'Yes','No, I do not.','Yes');
switch answer
    case 'Yes'
       estimaOtherWell
    case 'No, I do not.'
        return;
end