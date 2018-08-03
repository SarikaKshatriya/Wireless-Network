%implementation of viterbi algorithm
clc;
data=[];
tic;
%generate data of random binary sequence
%take system time(cputime) in nanoseconds
for i=1:1:10
ms=round(toc*1000*60*60*60);
r=mod(ms,2);
if(r==1)
     data=[data,r];
else
    data=[data,r];
end
end
 disp(data);
%call function to encode data
endata=encode_data(data);
disp("Data Encoded");
disp(endata);
%add errors of 1 bit
%tic;
%p=1;
%take system time in milliseconds
%for i=1:1:p
%k=round(toc*1000*60);
%if(k==0)
 %   if the value is ignore it
%else
 %   if(endata(k)==1)
  %      endata(k)=0;
  %  else
   %     endata(k)=1;
   % end
   % end
   %end
%disp("data with error bit");
%disp(p);
%disp("And the position of bit changed is");
%5disp(k);
p=viterbidec(endata);
data1=p;
disp("Data Decoded.");
disp(data1);
temp=1;
ldata=length(data);

%compare the input data and decoded data is equal or not
for i=1:1:ldata
    if data(i)==data1(i)
        % disp("equal");
     else
        temp=temp+1;
     end
  
end
if (temp>1)
         disp("Not equal");
else
       disp("Equal");
end
 
function [code]= encode_data(message1) 
%As the encoder is 1/2=1/n
%and n is length of generated codeword
for i=1:length(message1)
    message(i)= num2str(message1(i));
end 
state='00';
next_state='00';
code1=[];
message=[message '00'];
message=[message];
for t=1:length(message)
    inp= message(t);
    state=next_state;
    if(state=='00')
        if(inp=='0')
            next_state='00';
            outp='00';
        else
            next_state='10';
            outp= '11';
        end
        elseif(state=='10')
            if(inp=='0')
                next_state='01';
                outp='10';
            else
                next_state='11';
                outp= '01';
            end
        elseif(state=='01')
            if(inp=='0')
                next_state='00';
                outp='11';
            else
                next_state='10';
                outp= '00';
            end
        elseif(state=='11')
            if(inp=='0')
                next_state='01';
                outp='01';
            else
                next_state='11';
                outp= '10';
            end
end
code1= [code1 outp]; 
end 
for i=1:length(code1)
    code(i)= str2num(code1(i));
end
end

function [dec_op]=viterbidec(rcvdmsg)
% as our convolutional code is with 2 codeword then to make it simple 
%combine 2 bits in 1 
input=[];
for j=1:2:length(rcvdmsg)
   input=[ input (rcvdmsg(j))* 2 + (rcvdmsg(j+1))];
end
%it produces 0 for 00,1 for 01,2 for 10  and 3 for 11
%initializing all arrays
op_table=[00 00 11; 01 11 00; 10 10 01; 11 01 10]; %OUTPUT array
ns_table=[0 0 2; 1 0 2; 2 1 3; 3 1 3]; %NEXT STATE array
transition_table=[0 1 1 55; 0 0 1 1; 55 0 55 1; 55 0 55 1];
%There are 17 time instants which is made up of our 15-bit message plus 2 memory flush bits.
st_hist(1:4, 1:17)=55; %STATE HISTORY array
aem=zeros(4, 17); %ACCUMULATED ERROR METRIC (AEM) array
ssq=zeros(1, 17); %STATE SEQUENCE array

lim=length(input); %length of input
for (t=0:1:lim) %clock loop
% t 0 represents inital condition of encoder
    if(t==0)
        st_hist(1,1)=0;        %start at state 00
    else
        temp_state=[];%vector to store possible states at an instant
        temp_metric=[];%vector to store metrics of possible states  
        temp_parent=[];%vector to store parent states of possible states 
        
        for (i=1:1:4) 
            i; 
            in=input(t);
            if(st_hist(i, t)==55)  %if invalid state
                %do nothing
            else    
                ns_a=ns_table(i, 2)+1;    %next state if input is 0
                ns_b=ns_table(i, 3)+1;    %next state if input is 1
        
                op_a=op_table(i, 2);      %next possible output if input is 0
                op_b=op_table(i, 3);      %next possible output if input is 1
                
                cs=i-1;                   %current state
                %Branch metrics are the Hamming distance values at each time instant for 
                %the paths between the states at the previous time instant and 
                %the states at the current time instant.
                M_a=hamm_dist(in, op_a);  %branch metric for ns_a
                M_b=hamm_dist(in, op_b);  %branch metric for ns_b
          
                indicator=0; %flag to indicate redundant states
                        %ADD-COMPARE-SELECT Operation
                        %em_c: error metric of current state
                        %em_r: error metric of redundant state                
                for k=1:1:length(temp_state) %check next states
                    %if next possible redundant
                    if(temp_state(1,k)==ns_a) 
                        indicator=1;
                      %We add these branch metric values to 
                      %the previous accumulated error metric values 
                      %associated with each state.
                        em_c=M_a + aem(i,t);
                        em_r=temp_metric(1,k) + aem(temp_parent(1, k)+1,t);
                        %If the members of a pair of accumulated
                        %error metrics going into a particular state are equal, we just save that value
                        if( em_c< em_r)%compare the two error metrics
                            st_hist(ns_a,t+1)=cs;%select state with low AEM
                            temp_metric(1,k)=M_a;
                            temp_parent(1,k)=cs;
                        end
                    end
                    %if next possible state
                    if(temp_state(1,k)==ns_b)
                        indicator=1;
                        em_c=M_b + aem(i,t);
                        em_r=temp_metric(1,k) + aem(temp_parent(1, k)+1,t);
                        
                        if( em_c < em_r)%compare the two error metrics
                            st_hist(ns_b,t+1)=cs;%select state with low AEM
                            temp_metric(1,k)=M_b;
                            temp_parent(1,k)=cs;
                        end 
                    end 
                end     
                %if none of the 2 possible states are redundant
                if(indicator~=1)
                    %update state history table
                    st_hist(ns_a,t+1)=cs; 
                    st_hist(ns_b,t+1)=cs;
                    %update the temp vectors accordingly                   
                    temp_parent=[temp_parent cs cs];
                    temp_state=[temp_state ns_a ns_b];
                    temp_metric=[temp_metric M_a, M_b];
                end
             end   
        end
        %update the AEMs (accumulative error metrics) for all states for
        %current instant 't'
        for h=1:1:length(temp_state)
            xx1=temp_state(1, h);
            xx2=temp_parent(1, h)+1;
            aem(xx1, t+1)=temp_metric(1, h) + aem(xx2, t);
        end 
    end
end 
%trace back
%Select the state having the smallest accumulated error metric 
%and save the state number of that state.
for(t=0:1:lim)
    %take first col of aem
    slm=min(aem(:, t+1));
    slm_loc=find( aem(:, t+1)==slm );
    sseq(t+1)=slm_loc(1)-1;
end
% recreate the sequence of bits that Were input to the convolutional encoder.
dec_op=[];
for p=1:1:length(sseq)-1
    p;
    dec_op=[dec_op, transition_table((sseq(p)+1), (sseq(p+1)+1))];
end

%Hamming distance is the metric were going to use between the received symbol
%and the possible symbols.
%Returns the hamming distance b/w two 2 bit codes

function [HD]=hamm_dist(A,B)
HD=0;
for i=1:2
    a=bitget(A, i);
    b=bitget(B, i);
     if(a~=b)
        HD=HD+1;
    end
end
end
end