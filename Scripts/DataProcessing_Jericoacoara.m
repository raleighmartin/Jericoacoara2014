% Script for taking interpolated data and making useful basic calculations
% fit profile to BSNEs

%% 0. Initialize
clearvars;

%% 1. Assign folder and files with data, load stuff
folder_DataOutput = '../../../Google Drive/Data/AeolianFieldwork/Processed/'; %folder for storing data output
folder_Functions = '../../AeolianFieldworkAnalysis/Scripts/Functions/'; %folder with functions
addpath(folder_Functions); %point MATLAB to location of functions

%load metadata and interpolated data, create path for processed data
Metadata_Path = strcat(folder_DataOutput,'Metadata_Jericoacoara'); %get path to metadata
load(Metadata_Path);
InterpolatedData_Path = strcat(folder_DataOutput,'InterpolatedData_Jericoacoara'); %get path to interpolated data
load(InterpolatedData_Path);
ProcessedData_Path = strcat(folder_DataOutput,'ProcessedData_Jericoacoara'); %create path to processed data

%% 1. Process instrument heights
ProcessedData = ProcessInstrumentHeights(InterpolatedData);

%% 2. Process BSNE profiles
FluxBSNE = ProcessBSNEs(WeightBSNE,GrainSize_BSNE);
ProcessedData.FluxBSNE = FluxBSNE;

%% 3. Process Wenglors
[ProcessedWenglors, FluxWenglor] = ProcessWenglors(ProcessedData, FluxBSNE, InstrumentMetadata);
ProcessedData.Wenglor = ProcessedWenglors;
ProcessedData.FluxWenglor = FluxWenglor;

%% 4. Move extraneous metadata fields out of file
ProcessedData = MoveExtraneousMetadataFields(ProcessedData);

%% 5. Modify wind velocities so that u is oriented with setup (Jeri only)
Anemometers = fieldnames(ProcessedData.Ultrasonic);
N_Anemometers = length(Anemometers);
for i = 1:N_Anemometers
    U_old = ProcessedData.Ultrasonic.(Anemometers{i}); %get old anemometer data
    U_new = U_old; %initialize new as old
    N_windows = length(U_old); %go through each time interval
    for j = 1:N_windows
        U_new(j).u = U_old(j).v; %replace u with v
        U_new(j).v = U_old(j).u; %replace v with u
        U_new(j).v.raw = -U_new(j).v.raw; %take negative for v
        U_new(j).v.int = -U_new(j).v.int; %take negative for v
    end
    ProcessedData.Ultrasonic.(Anemometers{i}) = U_new; %replace new U in Processed Data
end
    
%% 6. Save processed data
save(ProcessedData_Path,'ProcessedData','-v7.3'); %save data

%% Restore function path to default value
restoredefaultpath;