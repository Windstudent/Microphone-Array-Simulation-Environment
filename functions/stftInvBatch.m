function [x] = stftInvBatch(stft,winLen,nFft,sampFreq)

% for periodic hann window
win = hann(winLen,'periodic');

% inits
n = 1:winLen;
iCol = 1;

nFrames = size(stft,2);
x = zeros(winLen+nFrames*winLen/2,1);

% perform inv stft
while iCol <= size(stft,2),
    % obtain block and window
    xBlock = ifft([stft(:,iCol);flipud(conj(stft(2:end-1,iCol)))],nFft);
    xBlock = xBlock(1:winLen);
    xwBlock = xBlock.*win;
    
    x(n) = x(n) + xwBlock;
    
    % update indices
    n = n + winLen/2;
    iCol = iCol + 1;
end
   