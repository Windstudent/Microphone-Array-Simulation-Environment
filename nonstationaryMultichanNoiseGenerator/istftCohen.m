function x=istftCohen(Y,nfft,dM,dN,wintype)
% istft : Inverse Short Time Fourier Transform
% ***************************************************************@
% Inputs: 
%    Y,     	stft of x;
%    nfft,  	window length;
%    dM,			sampling step in Time;
%    dN,			sampling step in Frequency;
%    wintype,	window type;
% Inputs: 
%    x,     	signal;
% Usage:
%    x=istft(Y,nfft,dM,dN,wintype);
% Defaults:
%    wintype='Hamming';
%    dN = 1;
%    dM = 0.5*nfft;
%    nfft=2*(size(Y,1)-1);

% Copyright (c) 2000. Dr Israel Cohen. 
% All rights reserved. Created  17/12/00.
% ***************************************************************@

if nargin == 1
	nfft = 2*(size(Y,1)-1);
end
if nargin < 3
   dM = 0.5*nfft;
   dN = 1;
end
if nargin < 5
	wintype = 'Hamming';
end

if exist(wintype)
   win=eval([lower(wintype),sprintf('(%g)',nfft)]);
else
   error(['Undefined window type: ',wintype])
end

N=nfft/dN;
%extend the anti-symmetric range of the spectum
%In case that the number of frequency bins is nfft/2+1
if size(Y,1) ~= nfft    
    Y(N/2+2:N,:)=conj(Y(N/2:-1:2,:));  
end

% Computes IDFT for each column of Y
Y = ifft(Y);  %Y=real(ifft(Y));
Y=Y((1:N)'*ones(1,dN),:);

% Apply the synthesis window
ncol=size(Y,2);
Y = win(:,ones(1,ncol)).*Y;

% Overlapp & add
x=zeros((ncol-1)*dM+nfft,1);
idx=(1:nfft)';
start=0;
for l=1:ncol
   x(start+idx)=x(start+idx)+Y(:,l);
   start=start+dM;
end

% Cancelling the artificial delay at the beginning an end of the input 
% signal x[n] (see stft.m)
% Note that we're not cancelling the delay at the end of the signal (because
% we don't have nx - the length of x[n] before the zeros padding). Hence,
% the reconstructed signal will 'suffer' from zeros padding at its end
delay1 = nfft-1;
x = x(delay1+1:end);