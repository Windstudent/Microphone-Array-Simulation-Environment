function [mcSignals,setup] = multichannelSignalGenerator(setup)


%-----------------------------------------------------------------------
%  Producing the multi_noisy_signals for Mic array Beamforming.
% 
%  Usage:  multichannelSignalGenerator(setup)
%         
%			setup.nRirLength : The length of Room Impulse Response Filter
%			setup.hpFilterFlag  : use 'false' to disable high-pass filter, the high-pass filter is enabled by default
%			setup.reflectionOrder : reflection order, default is -1, i.e. maximum order.
%			setup.micType : [omnidirectional, subcardioid, cardioid, hypercardioid, bidirectional], default is omnidirectional.
%           
%			setup.nSensors : The numbers of the Mic
%			setup.sensorDistance : The distance between the adjacent Mics (m)
%			setup.reverbTime : The reverberation time of room
%			setup.speedOfSound : sound velocity (m/s)
%
%			setup.noiseField : Two kinds of Typical noise field, 'spherical' and 'cylindrical'
%			setup.sdnr : The target mixing snr for diffuse noise and clean siganl.
%			setup.ssnr : The approxiated mixing snr for sensor noise and clean siganl.
%
%			setup.roomDim : 1 x 3 array specifying the (x,y,z) coordinates of the room (m).           
%			setup.micPoints : 3 x M array, the rows specifying the (x,y,z) coordinates of the mic postions (m). 
%			setup.srcPoint  : 3 x M array, the rows specifying the (x,y,z) coordinates of the  audio source postion (m). 
%
%			srcHeight : The height of target audio source
%			arrayHeight : The height of mic array
%
%			arrayCenter : The Center Postion of mic array 
%
%			arrayToSrcDistInt :The distance between the array and audio source on the xy axis
%
%			
%
%
%         
%
%  How To Use : JUST RUN
%
%  
%   
% Code From: Audio analysis Lab of Aalborg University (Website: https://audio.create.aau.dk/),
%            slightly modified by Wind at Harbin Institute  of Technology, Shenzhen, in 2018.3.24
%
% Copyright (C) 1989, 1991 Free Software Foundation, Inc.
%-------------------------------------------------------------------------



addpath([cd,'\..\rirGen\']);

%-----------------------------------------------initial parameters-----------------------------------

setup.nRirLength = 2048;
setup.hpFilterFlag = 1;
setup.reflectionOrder = -1;
setup.micType = 'omnidirectional';
setup.nSensors = 4;
setup.sensorDistance = 0.05;
setup.reverbTime = 0.1;
setup.speedOfSound = 340;

setup.noiseField = 'spherical';
setup.sdnr = 20;
setup.ssnr = 25;

setup.roomDim = [3;4;3];

srcHeight = 1;
arrayHeight = 1;

arrayCenter = [setup.roomDim(1:2)/2;1];

arrayToSrcDistInt = [1,1];

setup.srcPoint = [1.5;1;1];

setup.micPoints = generateUlaCoords(arrayCenter,setup.nSensors,setup.sensorDistance,0,arrayHeight);


[cleanSignal,setup.sampFreq] = audioread('..\data\twoMaleTwoFemale20Seconds.wav');

%---------------------------------------------------initial end----------------------------------------



%-------------------------------algorithm processing--------------------------------------------------

if setup.reverbTime == 0,
    setup.reverbTime = 0.2;
    reflectionOrder = 0;
else
    reflectionOrder = -1;
end

rirMatrix = rir_generator(setup.speedOfSound,setup.sampFreq,setup.micPoints',setup.srcPoint',setup.roomDim',...
    setup.reverbTime,setup.nRirLength,setup.micType,setup.reflectionOrder,[],[],setup.hpFilterFlag);

for iSens = 1:setup.nSensors,
    tmpCleanSignal(:,iSens) = fftfilt(rirMatrix(iSens,:)',cleanSignal);
end
mcSignals.clean = tmpCleanSignal(setup.nRirLength:end,:);
setup.nSamples = length(mcSignals.clean);

mcSignals.clean = mcSignals.clean - ones(setup.nSamples,1)*mean(mcSignals.clean);

%-------produce the microphone recieved clean signals---------------------------------------------

mic_clean1=10*mcSignals.clean(:,1); %Because of the attenuation of the recievd signals,Amplify the signals recieved by Mics with tenfold
mic_clean2=10*mcSignals.clean(:,2);
mic_clean3=10*mcSignals.clean(:,3);
mic_clean4=10*mcSignals.clean(:,4);
audiowrite('mic_clean1.wav' ,mic_clean1,setup.sampFreq);
audiowrite('mic_clean2.wav' ,mic_clean2,setup.sampFreq);
audiowrite('mic_clean3.wav' ,mic_clean3,setup.sampFreq);
audiowrite('mic_clean4.wav' ,mic_clean4,setup.sampFreq);

%----------------------------------end--------------------------------------------------

addpath([cd,'\..\nonstationaryMultichanNoiseGenerator\']);

cleanSignalPowerMeas = var(mcSignals.clean);


mcSignals.diffNoise = generateMultichanBabbleNoise(setup.nSamples,setup.nSensors,setup.sensorDistance,...
    setup.speedOfSound,setup.noiseField);
diffNoisePowerMeas = var(mcSignals.diffNoise);
diffNoisePowerTrue = cleanSignalPowerMeas/10^(setup.sdnr/10);
mcSignals.diffNoise = mcSignals.diffNoise*...
    diag(sqrt(diffNoisePowerTrue)./sqrt(diffNoisePowerMeas));

mcSignals.sensNoise = randn(setup.nSamples,setup.nSensors);
sensNoisePowerMeas = var(mcSignals.sensNoise);
sensNoisePowerTrue = cleanSignalPowerMeas/10^(setup.ssnr/10);
mcSignals.sensNoise = mcSignals.sensNoise*...
    diag(sqrt(sensNoisePowerTrue)./sqrt(sensNoisePowerMeas));

mcSignals.noise = mcSignals.diffNoise + mcSignals.sensNoise;
mcSignals.observed = mcSignals.clean + mcSignals.noise;

%------------------------------processing end-----------------------------------------------------------




%----------------produce the noisy speech of MIc in the specific ervironment sets------------------------

noisy_mix1=10*mcSignals.observed(:,1); %Amplify the signals recieved by Mics with tenfold
noisy_mix2=10*mcSignals.observed(:,2);
noisy_mix3=10*mcSignals.observed(:,3);
noisy_mix4=10*mcSignals.observed(:,4);
l1=size(noisy_mix1);
l2=size(noisy_mix2);
l3=size(noisy_mix3);
l4=size(noisy_mix4);
audiowrite('diffused_babble_noise1_20dB.wav' ,noisy_mix1,setup.sampFreq);
audiowrite('diffused_babble_noise2_20dB.wav' ,noisy_mix2,setup.sampFreq);
audiowrite('diffused_babble_noise3_20dB.wav' ,noisy_mix3,setup.sampFreq);
audiowrite('diffused_babble_noise4_20dB.wav' ,noisy_mix4,setup.sampFreq);


%-----------------------------end-------------------------------------------------------------------------
