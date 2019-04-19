%% This thing works ..... yeah
x=1;
snri=-6:x:10;%x is number of points to interleave
M=4;        %Number of receiver for one Tx
NosWords=100;
m=10; 
packetLength=2^m-1;
k=533;%provides error correctability of 54 errors 
%% plotting
h = gcf;
grid on;
hold on;
ax = gca;
ax.YScale = 'log';
xlim([snri(1), snri(end)]);
ylim([1e-6 1]);
xlabel('SNR (dB)');
ylabel('BER');
h.NumberTitle = 'off';
h.Renderer = 'zbuffer';
h.Name = 'Transmit vs Receive Diversity';
title('Transmit vs. Receive Diversity');
%%
BEROP=zeros(1,length(snri));

BEROP2=zeros(1,length(snri));

Nt=1;
Nr=M;
i=0;
for snr=snri(1):x:snri(end);
    i=i+1;
    if snr>5
        NosWords=300;
    end
    op2_sum=0;
    
    Before_Data_Array=gf(randi([0,1],NosWords,k));      % Orignal Data
    EncodedData_Array=bchenc(Before_Data_Array,packetLength,k);     % Encoded Data       
    EncodedData_Array=double(EncodedData_Array.x);
    ReceiveData_Array=zeros(NosWords,packetLength);
    
    for idx = 1:NosWords
        amt=packetLength;        
        %% Make the data
        
        EncodedData=EncodedData_Array(idx,:);
        data=EncodedData*2 - 1;                             % ModulatedData
                
        dataToSend=repmat(data,M,1);
        s=dataToSend;
        %% make AWGN channel and now reyleigh channel
        H=zeros(M,amt);
        H(:,:)=(randn(M,amt)+1i*randn(M,amt))/sqrt(2);
        r=H.*s;
        %% Adding AWGN To sent signal
        AWGN = comm.AWGNChannel('NoiseMethod', 'Signal to noise ratio (SNR)', 'SignalPower', 1);
        AWGN.SNR = snr;
        y=step(AWGN,r);
        %% Building combiner output
        y_copy=y;
        H2=conj(H);
        s_est= H2.*y_copy;            % s_estimate
        s_est=sum(s_est);
        %% MLD
        op=(s_est>0)*2-1;
        check=abs(op-data);
        
        ReceiveData_Array(idx,:)=(s_est>0);
        
        op2=sum(check)/2;
        op2_sum=op2_sum+op2;
    end
    
    DecodedData_Array=bchdec(gf(ReceiveData_Array),packetLength,k);
    DecodedData_Array=double(DecodedData_Array.x);
    Before_Data_Array=double(Before_Data_Array.x);
    Error__Data_Array=abs(DecodedData_Array-Before_Data_Array);
    TotalErrors=sum(sum(Error__Data_Array));
    ErrorRate_orgData=TotalErrors/(k*NosWords);
    BEROP2(1,i)=ErrorRate_orgData;
    semilogy(snr,ErrorRate_orgData,'mp');
    
    op3=op2_sum/(amt*NosWords);
    semilogy(snr, op3, 'kh');
    BEROP(1,i)=op3;
    drawnow;
end
fit1=berfit(snri,BEROP);
semilogy(snri,fit1,'k');