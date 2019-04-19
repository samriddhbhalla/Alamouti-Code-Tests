%% Quadrature Amplitude Modulation with Bit Inputs
% Modulate a sequence of bits using 64-QAM. Pass the signal through a noisy
% channel. Display the resultant constellation diagram.
%%
% Set the modulation order, and determine the number of bits per symbol.
M = 16;
k = log2(M);
%%
% Create a binary data sequence. When using binary inputs, the number of
% rows in the input must be an integer multiple of the number of bits per
% symbol.
data = randi([0 1],10000*k,1);
%%
% Modulate the signal using bit inputs, and set it to have unit average
% power.
txSig = qammod(data,M,'InputType','bit','UnitAveragePower',true);
txSig2 = qammod(data,M,'UnitAveragePower',true,'plotConstellation',true);
%%
% Pass the signal through a noisy channel.
rxSig = awgn(txSig,19);
%%
% Plot the constellation diagram.
cd = comm.ConstellationDiagram('ShowReferenceConstellation',false);
step(cd,rxSig)
%%
demodRxSig = qamdemod(rxSig,M,'OutputType','bit','UnitAveragePower',true);
%%
err=sum(mod((demodRxSig-data),2));
BER=err/(10000*k);