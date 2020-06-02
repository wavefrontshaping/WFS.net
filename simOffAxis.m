

%% Simple code to simulate phase demodulation with off-axis holography %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%% Number of pixels on the CCD

Ax = 256;     
Ay = 256;



%% Create the spatial grid 

[Xa,Ya] = meshgrid(1:Ax,1:Ay);  % for the CCD pixels array



%% Complex image to reconstruct

% we simulate a speckle pattern of grain size ~ grainSize
grainSize = 8;
temp  =rand(Ax,Ay)-.5+(rand(Ax,Ay)-.5)*sqrt(-1);
Filter2D = fspecial('gaussian', Ax, Ax/grainSize *1/2.35482);
Es = filter2(Filter2D,temp);
Es = Es./abs(Es);   


%% Didplay the target phase mask
figure,imagesc(angle(Es)); title('Complex phase wavefront'); axis square; colormap(hsv); axis off;


%% Generate the reference wavefront

% the term kSinTheta correspond to the spatial frequency of the fringes and has to
% be at least bigger that the maximal spatial frequency of the signal
% we choos here to have 4 periods of fringes in one speckle grain
kSinTheta = 4*2*pi*grainSize/Ax;

E0 = exp(sqrt(-1)*kSinTheta*Xa)*1/4;   % reference signal projected on a plane perpendicular to the propagation axis of the signal wavefront
E0 = E0*exp(-sqrt(-1)*pi/4);% the -pi/4 is just to have the same phase reference for the reconstructed image


%% Didplay the reference phase 
figure,imagesc(angle(E0));  axis square; colormap(hsv); axis off;

%% Intensity of the intereference pattern
I = abs(E0 + Es).^2;

%% Show the result of the interefences
figure,imagesc(I); colormap(gray); axis off; axis square;

%%%%%%%%% Reconstruction of the signal

%% Fourier transform of the intensity pattern
nb = 3;  % if nb = 1 =, no zero padding / nb > 1, add zeros in the Fourier tranform, see the help of fft2
Fh = fftshift(fft2(I,nb*Ax,nb*Ay));



%% Create the vector of the spatial frequencies
Sfreq = (-1/2:1/(nb*Ax):1/2-1/(nb*Ax));

%% Frequency grid
[Sx,Sy] = meshgrid(Sfreq,Sfreq);  


%% Display the absolute value of the Fourier transform
figure,imagesc(Sfreq,Sfreq,abs(Fh));  axis square;  caxis([0 5463])



%%%%%%
% Now we want to do a filtering of the spatial frequencies to keep only the
% -1 order
freq = kSinTheta/(2*pi);    % center frequency of the first orders
width = freq;             % width of the filtering window


%% First create the mask, we want to conseve the spatial frequencies around minus the carrier frequency ('-freq') with a window of size 'width'
Mask1 = (Sx > -freq-width/2).*(Sx < -freq+width/2);

%% We get the field in the Fourier plane after filtering
Fh2 = Fh.*Mask1;
% Display it
figure,imagesc(Sfreq,Sfreq,abs(Fh2));  axis square;

%% We shift the spatial frequencies around zero to remove the effect of the angular tilt due to -1 order
Mask2 = (Sx > -width/2).*(Sx < width/2);  % window centered around 0 of width 'width' 
I1 = find(Mask1);    % gets the indices corresponding to Mask1
I2 = find(Mask2);    % gets the indices corresponding to Mask2
Fh3 = zeros(size(Fh));
Fh3(I2) = Fh2(I1);    % copy the Fourier tranform at the position of the window centered around 0

% Display it
figure,imagesc(Sfreq,Sfreq,abs(Fh3));  axis square;

%% Get the field after the second length
tempIFT = ifft2(ifftshift(Fh3));
finalField = tempIFT(1:Ax,1:Ay);




%% Display the target phase map and the generated one
figure,
subplot 121
imagesc(angle(Es)); axis square; caxis([-pi pi]); colormap(hsv); axis off; title('Initial phase')
subplot 122
imagesc(angle(finalField)); axis square; caxis([-pi pi]); colormap(hsv); axis off; title('Reconstructed phase')


