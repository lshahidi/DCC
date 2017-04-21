clear all


addpath(genpath('./PRT'));
addpath(genpath('./NMT'));
addpath(genpath('./Code'));
addpath(genpath('./Sentences'));
addpath(genpath('./Histograms'));
addpath(genpath('./ExampleIdentifyMasking'));
addpath(genpath('./log4m'));

%experimentally simulate detection of speech signal in ssn

%assume noise variance is one and change d_squared values 
d_squared = 1;
N = 10000;

token = generateTokenStructure('asa.wav');
signal = token.wav;


ssn_power = 250;
niceday = generateTokenStructure('HeresANiceQuietPlaceToRest.wav');

for n = 1:N
    powerNoise = (sum(signal.^2)/size(signal,1))/(d_squared*1/1);
    noise = rand(size(signal))*powerNoise;
    signal = signal + noise;
    signal = sqrt(d_squared).*signal.*sqrt(1/sum(signal.^2));
    token.wav = signal;
    ssn = addSpeechShapedNoise_noiseLengthSameAsToken(token);%,d_squared);
    ssn = ssn.wav(1:length(signal));
    ssn = sqrt(d_squared).*ssn.*sqrt(1/sum(ssn.^2)).*ssn_power;
    ssn = ssn.*1/5000;

    x_h0 = ssn;
    x_h1 = signal + ssn;

    likelihood_h1(n) = real(x_h1'*signal - d_squared/2);
    likelihood_h0(n) = real(x_h0'*signal - d_squared/2);
end

thresholds = sort([likelihood_h1 likelihood_h0]);
for i = 1:length(thresholds)
    pf_1(i) = sum(likelihood_h0 > thresholds(i))/N;
    pd_1(i) = sum(likelihood_h1 > thresholds(i))/N;
end

%figure
%plot(pf_1,pd_1,'LineStyle','-','Marker','none')

%hold all

%detection of known speech signal in speech shaped noise with uncertain
%variance

%assume noise variance is one and change d_squared values 
d_squared = 1;
N = 10000;

%normalize signal to have d_squared energy:
token = generateTokenStructure('asa.wav');
signal = token.wav;
signal = sqrt(d_squared).*signal.*sqrt(1/sum(signal.^2));

noise_var = normrnd(0.183965,1,[1,1]);
d_squared = d_squared/noise_var; %update d_squared to include actual noise variance

%roc is a vertical line!
for n = 1:N
    noise = normrnd(0,sqrt(noise_var),size(signal));
    
    x_h0 = noise;
    x_h1 = signal + noise;

    likelihood_h1(n) = x_h1'*signal - d_squared/2;
    likelihood_h0(n) = x_h0'*signal - d_squared/2;
end

thresholds = sort([likelihood_h1 likelihood_h0]);
for i = 1:length(thresholds)
    pf_2(i) = sum(likelihood_h0 > thresholds(i))/N;
    pd_2(i) = sum(likelihood_h1 > thresholds(i))/N;
end

%figure
%plot(pf_2,pd_2,'LineStyle','-','Marker','none')

%detection of known speech signal in speech shaped noise with uncertain
%variance and uncertain mean

%assume noise variance is one and change d_squared values 
d_squared = 1;
N = 10000;

%normalize signal to have d_squared energy:
token = generateTokenStructure('asa.wav');
signal = token.wav;
signal = sqrt(d_squared).*signal.*sqrt(1/sum(signal.^2));

noise_var = normrnd(0.183965,1,[1,1]);
d_squared = d_squared/noise_var; %update d_squared to include actual noise variance
noise_mean = normrnd(0,1,[1,1]);

%roc is a vertical line!
for n = 1:N
    noise = normrnd(noise_mean,sqrt(noise_var),size(signal));
    
    x_h0 = noise;
    x_h1 = signal + noise;

    likelihood_h1(n) = x_h1'*signal - d_squared/2;
    likelihood_h0(n) = x_h0'*signal - d_squared/2;
end

thresholds = sort([likelihood_h1 likelihood_h0]);
for i = 1:length(thresholds)
    pf_3(i) = sum(likelihood_h0 > thresholds(i))/N;
    pd_3(i) = sum(likelihood_h1 > thresholds(i))/N;
end

%figure
%plot(pf_3,pd_3,'LineStyle','-','Marker','none')

save('Case2.mat')
