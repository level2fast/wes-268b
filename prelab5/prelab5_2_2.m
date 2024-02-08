% This script produces a simulation of a QPSK modulator/demodulator with coding. 

%% Create  Data source which consists of a random sequence of 0's and 1's
% Parameters
num_symbols = 64;  % Number of QPSK symbols
data_bits = randi([0, 1], 1, 2 * num_symbols);  % Random binary data

% QPSK Modulation
modulated_symbols = qpsk_modulate(data_bits);

%%  Separate the data source into two data streams for the I and Q channels
% Separate data into I and Q channels
I_channel = real(modulated_symbols(1:2:end));
Q_channel = real(modulated_symbols(2:2:end));

% Plot the QPSK constellation diagram
scatter((I_channel), (Q_channel), 'o');
title('QPSK Constellation Diagram');
xlabel('I Channel');
ylabel('Q Channel');
axis square;
%% Channel code each stream using the repeat (3,1) code
i_modulated_symbols_encoded = repetition_code_encode(I_channel);
q_modulated_symbols_encoded = repetition_code_encode(Q_channel);
%% Scramble the coded sequence using a scrambler
i_scrambled_data = scramble_data(i_modulated_symbols_encoded,5);
q_scrambled_data = scramble_data(q_modulated_symbols_encoded,5);

%% Use a single sample per symbol
k = 1;   % information bits
n = 3;    % total bits
Rc = k/n; % code rate

i_rect_pulse = i_scrambled_data;
i_rect_pulse(i_rect_pulse > 0) = 1;
i_rect_pulse(i_rect_pulse < 0) = -1;

q_rect_pulse = q_scrambled_data;
q_rect_pulse(q_rect_pulse > 0) = 1;
q_rect_pulse(q_rect_pulse < 0) = -1;

% This assumes that the transmitted pulse shape is rectangular and 
% modulation mapping for each binary data stream
Eb_N0_dB = -10:0.5:10;       % Range of Eb/N0 values in dB
Eb_N0 = 10.^(Eb_N0_dB / 10); % Convert dB to linear scale

BER = zeros(1,length(Eb_N0));  % pre-allocate BER vector
Pe  = 0;            % probability of a bit error
Ps  = 0;            % probability of symbol error
N   = 1;            % samples per symbol

% Set the random seed for reproducibility
rng(42);

% Generate independent zero-mean Gaussian random variable with variance of 1/2
std_deviation = sqrt(1/2);
noise = std_deviation * randn(1, length(i_rect_pulse));
i_rect_pulse_noisy = noise + i_rect_pulse;
q_rect_pulse_noisy = noise + q_rect_pulse;

bits = zeros(1, num_symbols);  % bits
rBits = zeros(1,num_symbols);  % received bits
n = zeros(1,num_symbols*N);    % noise vector
x = zeros(1,num_symbols*N);    % data vector    
e = zeros(1,num_symbols*N);    % error vector
y = zeros(1,num_symbols*N);    % received vector
std_deviation = sqrt(1/2);

% for each signal to noise ratio
for idx=1:length(Eb_N0)
    num_errors = 0;
    num_bits   = 0;

    % calc amplitude of qpsk symbol
    A = sqrt(Rc * Eb_N0(idx)); 
    i_temp = i_rect_pulse_noisy*A;
    q_temp = q_rect_pulse_noisy*A;  
    while( num_errors < 200 )
        %% Modulator
        % Create  Data source which consists of a random sequence of 0's and 1's
        % Parameters
        data_bits = randi([0, 1], 1, 2 * num_symbols);  % Random binary data
        
        % QPSK Modulation
        modulated_symbols = qpsk_modulate(data_bits); 
       
        %  Separate the data source into two data streams for the I and Q channels
        % Separate data into I and Q channels
        I_channel = real(modulated_symbols(1:2:end));
        Q_channel = real(modulated_symbols(2:2:end));

        i_rect_pulse_uncoded = i_data_unscrambled;
        i_rect_pulse_uncoded(i_rect_pulse_uncoded > 0) = 1;
        i_rect_pulse_uncoded(i_rect_pulse_uncoded < 0) = 0;

        q_rect_pulse_uncoded = q_data_unscrambled;
        q_rect_pulse_uncoded(q_rect_pulse_uncoded > 0) = 1;
        q_rect_pulse_uncoded(q_rect_pulse_uncoded < 0) = 0;

        % Channel code each stream using the repeat (3,1) code
        i_modulated_symbols_encoded = repetition_code_encode(i_rect_pulse_uncoded);
        q_modulated_symbols_encoded = repetition_code_encode(q_rect_pulse_uncoded);
        
        % Scramble the coded sequence using a scrambler
        [i_scrambled_data, i_prbs] = scramble_data(i_modulated_symbols_encoded,5);
        [q_scrambled_data, q_prbs] = scramble_data(q_modulated_symbols_encoded,5);

        % Threshold data and apply pulse shaping
        i_rect_pulse = i_scrambled_data;
        i_rect_pulse(i_rect_pulse > 0) = 1;
        i_rect_pulse(i_rect_pulse == 0) = -1;
        i_rect_pulse = i_rect_pulse * A;

        q_rect_pulse = q_scrambled_data;
        q_rect_pulse(q_rect_pulse > 0) = 1;
        q_rect_pulse(q_rect_pulse == 0) = -1;
        q_rect_pulse =  q_rect_pulse * A;

        %% Channel 
        % Generate independent zero-mean Gaussian random variable with variance of 1/2
        noise = std_deviation * randn(1, length(i_rect_pulse));
        i_rect_pulse_noisy = noise + i_rect_pulse;
        q_rect_pulse_noisy = noise + q_rect_pulse;

        %% Receiver
        % Decode each of the unscrambled binary streams separately using a
        % majority logic rule.
        i_rect_pulse_decoded = i_data_unscrambled;
        i_rect_pulse_decoded(i_rect_pulse_decoded > 0) = 1;
        i_rect_pulse_decoded(i_rect_pulse_decoded < 0) = 0;

        q_rect_pulse_decoded = q_data_unscrambled;
        q_rect_pulse_decoded(q_rect_pulse_decoded > 0) = 1;
        q_rect_pulse_decoded(q_rect_pulse_decoded < 0) = 0;

        % unscramble the i/q data
        i_data_unscrambled = xor(i_rect_pulse_decoded, i_prbs);
        q_data_unscrambled = xor(q_rect_pulse_decoded, q_prbs);

        if(i_data_unscrambled != )

        % compute the total number of errors
        num_errors =+ i_error + q_error;

        % compute the probability of bit error(Pe) for BPSK
        Pe_theoretical = 0.5 * qfunc(sqrt(Eb_N0(idx)));

        % compute the probability of symbol error

        num_bits   =+ i_bits + q_bits;
    end 
   BER(idx) = numErrors/numBits;
end



% Plot the uncoded probability of a bit error and the uncoded probability of a symbol error for
% QPSK down to an error rate of about 10−4

% Plot the coded probability of a bit error for one quadrature components using the (3, 1) repeat
% code.

% Determine the coding gain at pe = 10−4 and compare this simulated value with theory
% for BPSK for a single quadrature component.
