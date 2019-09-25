function [stft,freq,time,blocks] = stftBatch(x,winLen,nFft,sampFreq)

% for periodic hann window
win = hann(winLen,'periodic');

% inits
n = 1:winLen;
iCol = 1;

nLowerSpec = ceil((1+nFft)/2);

% perform stft
while n(end) <= length(x);

    % obtain block and window
    xBlock = x(n); 
    xwBlock = xBlock;
    blocks(:,iCol) = xwBlock;

    % fft
    X = fft(xwBlock,nFft);
    
    % stft matrix
    stft(:,iCol) = X(1:nLowerSpec);
    
    % update indices
    n = n + winLen/2;
    iCol = iCol + 1;
    iTime(iCol) = mean(n-1);
end
   
% calc time + freq vectors
freq = (0:nLowerSpec-1)*sampFreq/nFft;
time = iTime/sampFreq;
