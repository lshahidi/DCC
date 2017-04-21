
function noisySig = addSpeechShapedNoise_noiseLengthSameAsToken(WD,SNR,taps)

%ADDSPEECHSHAPEDNOISE - Generate speech shaped noise based on HINT, i.e.
%from Nilsson et al. (1994), and randomly place all of the tokens in wav
%directory input in specified level of that noise
%
% Edited by JMD to ensure that the length of the noise is equal to the
% length of the speech token.
%
% Syntax:  noisySig = addSpeechShapedNoise(WD,SNR)
%
% Inputs:
%    WD - wav directory structure containing the fields '.wav' and
%    '.fs'
%    SNR - Desired signal-to-noise ratio
%
% Outputs:
%    noisySig - Wav directory structure with noisy versions of input
%
% Example:
%    Line 1 of example
%    Line 2 of example
%    Line 3 of example
%
% Other m-files required: none
% Subfunctions: none
% MAT-files required: none
%
% See also: OTHER_FUNCTION_NAME1,  OTHER_FUNCTION_NAME2

% Author: Joshua Stohl
% Duke University, Department of Electrical and Computer Engineering
% email: jss@ee.duke.edu
% Created: 21-Mar-2008
% Last revision: 24-Mar-2008

%---------------------------------------
if nargin < 2 || isempty(SNR)
    SNR = 0;
end
if nargin < 3 || isempty(taps)
    taps = 78;
end

if ~isfield(WD,'wav') && ~isfield(WD,'fs')
    error('Input structure should contain fields ''.wav'' and ''.fs'' .');
end

if length(unique([WD.fs])) > 1
    error('Wave Directory structure should contain wavs with identical sampling frequencies.');
else
    fs = unique([WD.fs]);
end

for iWave = 1:numel(WD)
    WD(iWave).length = length(WD(iWave).wav);
end

noisySig = struct('wav',[],'fs',[]);
for i = 1:size(WD,2)
    noiseLength = WD(i).length;
    
    % Generate SSN
    noise = randn(noiseLength,1);
    [b,a] = generate_speech_spectrum_coeffs(taps);
    noise = filter(b,a,noise)';
    
    P_n = sum(noise.^2,2)'./noiseLength;
    P_s = sum(WD(i).wav.^2)./WD(i).length;
    
    scale = sqrt(1./((10.^(SNR/10).*P_n)./P_s))';
    scaledNoise = scale*noise;

    noisySig(i).fileName = WD(i).fileName;
    noisySig(i).wav = scaledNoise';
    noisySig(i).wav = noisySig(i).wav+WD(i).wav;

%     noisySig(i).wav = noisySig(i).wav.*tukeywin(noiseLength,.1);
    noisySig(i).fs  = WD(i).fs;
    noisySig(i).length = WD(i).length;
    noisySig(i).pathName = WD(i).pathName;
end

noisySig = normalizeWavDirectory(noisySig);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [b,a] = generate_speech_spectrum_coeffs(taps)

if nargin == 0
    taps = 78;  % See Nilsson et al. (1994)
end

[x,fs] = audioread('cnoise.wav');
a = lpc(x(22050:132300),taps); % Use 5 seconds of noise to generate coeffs
b = 1;

%---------------------------------------
%Please send suggestions for improvement of the above code
%to the author at this email address: jss@ee.duke.edu
