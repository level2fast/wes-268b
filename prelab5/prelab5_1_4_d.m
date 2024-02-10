%% Problem 1.4.d
% MATLAB script for determining if the senseword vector b =[ 1 1 1 1 1 1 1]
% is a valid codeword, calculating the syndrome vector, and finding the most
% likely transmitted codeword through error correction.
%% Define parity check matrix and arbitrary row vector
% Lets say we are given a parity check matrix (H). 
H = [1,0,1,1,1,0,0;
     1,1,0,1,0,1,0;
     0,1,1,1,0,0,1];

% Create arbitrary row vector to determine if it's a valid codeword, i.e.
% determine if it was generated by the generator matrix (G).
b =[ 1 0 0 0 0 0 1];

%% Problem 1.4.d.i Check if the codeword is a valid codeword using the parity check matrix (H)
% Calculate the syndrome
syndrome = mod(b * H', 2);  
fprintf('syndrome vector: [')
fprintf('%d, ', syndrome(1:end-1))
fprintf('%d]\n', syndrome(end))

% If the syndrome is all zeros, the codeword is valid
isValid = all(syndrome == 0);

if isValid
    disp('The codeword is valid.');
else
    disp('The codeword is invalid.');
end
%% %% Problem 1.4.d.ii Now find the most likely transmitted codeword
% Find the position of the codeword error in the syndrome. 
errorPosition = (bin2dec(num2str(flip(syndrome))) - length(b)) +1;
% Correct the error
b(errorPosition) = mod(b(errorPosition) + 1, 2);
decodedCodeword = b;

fprintf("Most likely transmitted codeword\n");
fprintf('decoded codeword vector: [')
fprintf('%d, ', decodedCodeword(1:end-1))
fprintf('%d]\n', decodedCodeword(end))