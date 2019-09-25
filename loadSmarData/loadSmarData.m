%% loadSmarData
% Load a dataset and associated setup from the SMAR database
%
%% Syntax:
%# smarData = loadSmarData(audioPath,audioName)
%
%% Description:
% Load a dataset and associated setup from the SMAR database. The SMAR
% database consists of 960 audio recordings for 48 different configurations
% of the loudspeaker and microphone array. For each configuration, 20 audio
% segments is recorded. The names of these audio segments are:
% * Artificial signals:
% # 5s_silence_48kHz
% # exp_swept_sinus_10Hz_24kHz
% # harm_sinus_48kHz
% # mls16_48kHz
% # pink_noise_48kHz
% # sinus_tones_48kHz
% # wgn_48kHz
% * Speech/vocal signals:
% # 44_soprano
% # 48_quartet
% # 50_male_speech_english
% # CA02_03
% # FA03_09
% # MD24_04
% * Musical signals:
% # 16_clarinet
% # 21_trumpet
% # 36_xylophone
% # 69_abba
% # BassFlute.ff.C6Db6
% # Guitar.ff.sulB.B3
% # Violin.arco.mf.sulA.A4B4.stereo
% 
% The 48 configurations are enumerated by a four digit number of the form ABCD.
% * The first and most significant digit A denotes the type of loudspeaker.
%   The loudspeaker types are:
% # 0XXX: The B&K OmniPower 4296 is used
% # 1XXX: The B&K OmniSource 4295 is used
% # 2XXX: A custom-made 3'' directional loudspeaker is used
% * The second digit B denotes the position of the loudspeaker. There are
%   two positions which are:
% # X0XX: (2.00, 6.50, 1.25) with an orientation of -90 degrees
% # X1XX: (3.50, 4.50, 1.50) with an orientation of -45 degrees
% * The third digit C denotes the type(s) of microphone arrays. There are
% three microphone array configurations.
% # XX0X: An orthogonal array, a single microphone, and a dummy microphone
% # XX1X: Three independent ULAs and a dummy microphone.
% # XX2X: Two independent circular arrays, a ULA, and a dummy microphone.
% * The least significant digit D denotes a particular layout of the microphone
%   positions. These are:
% # XX00:
% - Orth. array: (4.00, 1.50, 1.00) with an orientation of -90 degrees
% - Single MIC : (1.50, 3.00, 1.00) with an orientation of 90 degrees
% # XX01:
% - Orth. array: (4.00, 1.50, 1.50) with an orientation of -135 degrees
% - Single MIC : (1.50, 3.00, 1.10) with an orientation of 90 degrees
% # XX02:
% - Orth. array: (4.50, 3.50, 1.50) with an orientation of -90 degrees
% - Single MIC : (1.50, 3.10, 1.00) with an orientation of 90 degrees
% # XX03: 
% - Orth. array: (6.50, 2.50, 1.00) with an orientation of -45 degrees
% - Single MIC : (1.60, 3.00, 1.00) with an orientation of 90 degrees
% # XX10:
% - ULA A: (1.00, 0.50, 1.25) with an orientation of 0 degrees
% - ULA B: (4.00, 0.50, 1.25) with an orientation of 0 degrees
% - ULA C: (6.00, 0.50, 1.25) with an orientation of 0 degrees
% # XX11:
% - ULA A: (2.50, 3.50, 1.00) with an orientation of -45 degrees
% - ULA B: (4.00, 0.50, 1.25) with an orientation of 0 degrees
% - ULA C: (6.00, 3.00, 1.25) with an orientation of 45 degrees
% # XX20:
% - UCA A: (2.50, 2.00, 1.50) with rotations of 0 around x-axis, 0 around 
%   y-axis, and 180 around z-axis.
% - UCA B: (6.50, 3.50, 1.00) with rotations of 0 around x-axis, -90 around 
%   y-axis, and 90 around z-axis.
% - ULA C: (6.50, 1.50, 1.50) with an an orientation of 45 degrees 
% # XX21:
% - UCA A: (6.50, 3.50, 1.00) with rotations of 0 around x-axis, -90 around 
%   y-axis, and 90 around z-axis.
% - UCA B: (2.50, 2.00, 1.50) with rotations of 0 around x-axis, 0 around 
%   y-axis, and 180 around z-axis.
% - ULA C: (1.60, 2.50, 1.25) with an an orientation of -45 degrees
% The dummy microphone is always placed at (5.00, 0.20,1.00).
%
% NOTE that all coordinates above are for various reference positions.
% These are:
% * B&K OmniSource 4295: The top of the microphone stand (minus the length of
%   the top thread)
% * B&K OmniPower 4296: The top of the speaker stand.
% * Custom-made 3'' directional loudspeaker: The top of the microphone stand
%   (minus the length of the top thread)
% * Orthogonal array: The top of the microphone stand (minus the length of
%   the top thread)
% * Single mic: The top of the microphone stand (minus the length of the
%   top thread)
% * ULA: The top of the microphone stand
% * Circular array: The centre of the ball in the microphone mount adapter
% * Dummy mic: The top of the microphone stand (minus the length of the top
%   thread)
%
% The input and output variables of the function are
% * audioFolder: The absolute or relative path to the folder containing the
%   audio recordings.
% * audioName: The name of the audio segments. See above for the
%   possibilities.
% * smarData: A struct with two fields.
% # smarData.setup: The setup of the recording
% # smarData.dataMatrix: All recordings with the columnindex corresponding
%   to the channel number.
%
%% Examples:
% audioPath = 'smard/0000_20140114-1246';
% audioName = 'mls16_48kHz';
% smarData = loadSmarData(audioPath,audioName);
%
function smarData = loadSmarData(audioFolder,audioName)
    % load the configuration file
    setup = load([audioFolder,filesep,'setup_data.mat']);
    % load all recordings of the audio file
    recordingNameList = [setup.recConf.source.name,setup.recConf.mic.name,...
        setup.recConf.dummy.name];
    recordingChannelList = [setup.recConf.source.ch,setup.recConf.mic.ch,...
        setup.recConf.dummy.ch];
    % number of recordings
    nRecordings = length(recordingChannelList);
    % extract the first recording
    basename = [audioFolder,filesep,audioName];
    firstRecoding = audioread([basename,'_ch',num2str(recordingChannelList(1)),'_',...
        recordingNameList{1},'.flac']);
    % number of data points
    nData = length(firstRecoding);
    % data matrix (the column number correponds to the channel number)
    dataMatrix = nan(nData,nRecordings);
    dataMatrix(:,recordingChannelList(1)) = firstRecoding;
    for iRecording = 2:nRecordings
        dataMatrix(:,recordingChannelList(iRecording)) = ...
            audioread([basename,'_ch',...
            num2str(recordingChannelList(iRecording)),'_',...
            recordingNameList{iRecording},'.flac']);
    end
    % save the loaded data in a struct
    smarData.setup = setup;
    smarData.dataMatrix = dataMatrix;
end
