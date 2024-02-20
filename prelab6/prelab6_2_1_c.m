%% 2.c use a parallelizer to transform the serial data from a QPSK symbol mapper fed by a random bitstream
% Generate random binary data for QPSK modulation
clear
clf
% Parameters
num_symbols = 128;                     % Number of QPSK symbols
samples_per_symbol = 32;               % Sampling rate
rolloff = 0;                           % Rectangular pulse shaping (no roll-off)
symbol_rate = 1;                       % Symbol rate
fc = 2e3;                              % Carrier frequency
fs = samples_per_symbol * symbol_rate; % Sampling frequency

% Generate random binary data for QPSK modulation
data = randi([0 1], 1, 2*num_symbols);

% Map binary data to QPSK symbols
qpsk_symbols = 1/sqrt(2) * (2 * data(1:2:end) - 1 + 1j * (2 * data(2:2:end) - 1));

% Plot the QPSK constellation
scatterplot(qpsk_symbols);
title('QPSK Constellation Diagram');
xlabel('In-phase');
ylabel('Quadrature');
grid on;

% Modulate the pulse-shaped waveform onto the subcarrier
t = (0:length(qpsk_symbols)-1) / fs; % Time vector
subcarrier = exp(1j * 2 * pi * fc * t);

% Add a 2 new subcarriers
N = samples_per_symbol;
Ts = t(end);

f1_delta  = (1/N*Ts);
[ofdm_signal1, sub_carrier2] = add_subcarrier(subcarrier,fc + f1_delta,fs,num_symbols,N);

f2_delta  = (1/N*Ts);
[ofdm_signal2, sub_carrier3] = add_subcarrier(ofdm_signal1,fc - f2_delta,fs,num_symbols,N);

% convert symbols from serial to parallel
s_k = ofdm_parallelizer(symbol_values=ofdm_signal2);

% perform ifft to on parallelized data 
temp  = ifft(s_k);

% convert symbols from parallel to serial
s_t = ofdm_serializer(symbol_subcarrier_mat=temp);
%% c.i Plot the magnitude of power spectrum of the total transmitted signal s(t) with all subcarriers enabled
% Power spectrum plot
figure(1)
subcarrier = s_t;
subplot(2, 1, 1);
NFFT            = 2^nextpow2(length(subcarrier)); % Next power of 2 from length of signal
signal1_1       = subcarrier;
ofdm_fft1_1     = fft(signal1_1,NFFT)/length(signal1_1);
ofdm_shifted1_1 = fftshift(ofdm_fft1_1);
fshift1_1       = (-NFFT/2:NFFT/2-1) * (fs/NFFT);
ofdm_psd1_1     = abs(ofdm_shifted1_1).^2/NFFT; 
plot(fshift1_1, pow2db(ofdm_psd1_1));
title('2.1.c.i OFDM All Subcarriers - Power Spectrum');
xlabel('Frequency (Hz)');
ylabel('Power(db)');
grid on;




return
%% c.ii zero out subcarriers, Plot the power spectrum of s(t) with only three subcarriers enabled.
% subcarrier = s_t;
% subplot(2, 1, 1);
% NFFT = 2^nextpow2(length(subcarrier)); % Next power of 2 from length of y
% Y = fft(subcarrier,NFFT)/length(subcarrier);
% f = fs/2 * linspace(0,1,NFFT/2+1);
% ydft = Y(1:NFFT/2+1);
% psdx = abs(ydft).^2;
% plot(f,pow2db(psdx));
% title('QPSK Modulated Subcarrier - Power Spectrum');
% xlabel('Frequency (Hz)');
% ylabel('Power(db)');
% grid on;
%% Plot the real part of the corresponding time series for each case. 

% What happens if you try and view all of the subcarriers  constellations 
% overlaid on top of one another? What does this mean if you try and generate 
% an eye-pattern to find the optimal sampling time?






