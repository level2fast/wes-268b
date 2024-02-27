%% Theory Problems 
%% 1. Frequency offset correction using a periodic sequence
% The PLCP preamble field is used for synchronization. It consists of 10 
% identical short sequences and two identical long sequences. The sampling 
% rate for a this system is fs = 20 MHz and the length of the short and 
% long sequences are Tshort = 0.8µs and Tlong = 3.2µs.

%% 1.a Calculate Lshort and Llong in samples.
fs_hz   = 20e6;
t_short = 0.8e6;
t_long  = 3.2e6;
num_samples_short = fs_hz*(t_short/1e6);
num_samples_long = fs_hz*(t_long/1e6);
display(num_samples_long)
display(num_samples_short)

%% 1.b Consider the received time-series r[n], which consists of the above preamble time-series
% x[n] with a frequency offset f0 and initial phase offset ϕ0. Assume the following
% • Index n = n1 corresponds to the start-time of short sequence “t1”.
% • Index n = N1 corresponds to the start-time of long sequence “T1”.
% • The received time series can be written as r[n] = e
% j(2πf0n+ϕ0)x[n], and the frequency
% offset f0 stays constant for the duration of the preamble. Note that f0 is a normalized
% frequency given by f0 = ϵ/N = feTs where fe is the absolute frequency error and
% Ts is the sample time (see Lecture 8A).
% • There is no additive noise in the measurements of r[n].
% f0_short = 1/t_short;
% phi = 0;
% phase = 2*pi*f0_short*n+phi;
% x_n  = 0:1/fs_hz:t_short;
% r_n = exp(1j*phase*x_n);









